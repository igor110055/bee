import 'dart:convert';
import 'dart:math';

import 'package:beewallet/model/nft/nftinfo.dart';
import 'package:beewallet/model/node/node_model.dart';
import 'package:beewallet/model/tokens/collection_tokens.dart';
import 'package:beewallet/model/transrecord/trans_record.dart';
import 'package:beewallet/net/request_method.dart';
import 'package:beewallet/net/url.dart';
import 'package:beewallet/net/wallet_services.dart';
import 'package:beewallet/public.dart';
import 'package:beewallet/utils/date_util.dart';
import 'package:beewallet/utils/json_util.dart';
import 'package:decimal/decimal.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';

class ChainServices {
  static Future<dynamic> requestDatas(
      {required KCoinType? coinType, dynamic params}) async {
    String url = NodeModel.queryNodeByChainType(coinType!.index).content ?? "";
    dynamic result;
    result = await RequestMethod.manager!
        .requestData(Method.POST, url, data: params);
    return result;
  }

  static Future<dynamic> requestETHDatas(
      {required KCoinType kCoinType,
      required String path,
      Map<String, dynamic>? queryParameters,
      dynamic data}) async {
    String host = NodeModel.getBlockExploreApi(kCoinType);
    queryParameters ??= {};
    String url = host + path;
    if (kCoinType == KCoinType.BSC) {
      queryParameters["apikey"] = bsc_apiKey;
    }
    dynamic result = await RequestMethod.manager!.requestData(Method.GET, url,
        queryParameters: queryParameters, data: data);
    return result;
  }

  static Future<List<TransRecordModel>> requestETHTranslist(
      {required MCollectionTokens tokens,
      required KTransDataType kTransDataType,
      required String from,
      required int page}) async {
    List<TransRecordModel> datas = [];
    Map<String, dynamic> params = {};
    KCoinType coinType = tokens.chainType!.geCoinType();
    NodeModel model = NodeModel.queryNodeByChainType(coinType.index);
    int? chainid = model.chainID;
    int? decimal = tokens.decimals;
    String? symbol = tokens.token;

    params["module"] = "account";
    params["address"] = from;
    params["page"] = page;
    params["offset"] = 20;
    params["sort"] = "desc";
    if (tokens.isToken == false) {
      params["action"] = "txlist";
    } else {
      params["action"] = "tokentx";
      params["contractaddress"] = tokens.contract;
    }
    dynamic result = await requestETHDatas(
        kCoinType: coinType, path: "/api", queryParameters: params);
    if (result != null && result is Map) {
      String status = result["status"];
      if (status == "1") {
        List object = result["result"];
        for (var item in object) {
          String blockNumber = item["blockNumber"];
          String timeStamp = item["timeStamp"];
          String hash = item["hash"];
          String fromADD = item["from"];
          String to = item["to"];
          BigInt value = BigInt.parse(item["value"]);
          BigInt gasPrice = BigInt.parse(item["gasPrice"] ?? "0");
          String gasUsed = item["gasUsed"] ?? "0";
          String fee = TRWallet.configFeeValue(
              cointype: coinType.index,
              beanValue: gasUsed,
              offsetValue: gasPrice.tokenString(9));

          TransRecordModel model = TransRecordModel();
          model.txid = hash;
          model.fromAdd = fromADD;
          model.toAdd = to;
          model.fee = fee;
          model.amount =
              decimal == null ? value.toString() : value.tokenString(decimal);
          model.date = DateUtil.formatDateMs(int.parse(timeStamp) * 1000);
          model.coinType = coinType.coinTypeString();
          model.token = symbol;
          model.transStatus = KTransState.success.index;
          model.transType = KTransType.transfer.index;
          model.blockHeight = int.tryParse(blockNumber);
          model.chainid = chainid;
          datas.add(model);
        }
        TransRecordModel.insertTrxLists(datas);
      }
    }

    return TransRecordModel.queryTrxList(
        from, symbol ?? "ETH", chainid ?? 0, kTransDataType.index,
        limit: 10, offset: ((page - 1) * 10));
  }

  static Future requestTransactionReceipt(String tx, String url) async {
    String method = "eth_getTransactionReceipt";
    Map params = {
      "jsonrpc": "2.0",
      "method": method,
      "params": [tx],
      "id": tx,
    };
    return RequestMethod.manager!.requestData(Method.POST, url, data: params);
  }

  static Future<Map?> requestTokenInfo(
      {required KCoinType type,
      required String contract,
      required String walletAaddress}) async {
    NodeModel node = NodeModel.queryNodeByChainType(type.index);

    Map decimals = {
      "jsonrpc": "2.0",
      "id": "n",
      "method": "eth_call",
      "params": [
        {"to": contract, "data": "0x313ce567"},
        "latest"
      ]
    };
    Map symbol = {
      "jsonrpc": "2.0",
      "id": "n",
      "method": "eth_call",
      "params": [
        {"to": contract, "data": "0x95d89b41"},
        "latest"
      ]
    };
    dynamic result = await RequestMethod.manager!
        .requestData(Method.POST, node.content!, data: [decimals, symbol]);
    if (result == null) {
      return null;
    }
    List response = result as List;
    Map? object;
    for (var i = 0; i < response.length; i++) {
      Map params = response[i];
      if (params.keys.contains("result") && params["result"].length > 2) {
        String result = params["result"] as String;
        result = result.replaceAll("0x", "");
        object ??= {};
        if (i == 0) {
          int? decimal = int.tryParse(result, radix: 16);
          LogUtil.v("decimal $decimal");
          object["decimal"] = decimal;
        } else if (i == 1 && result.length == 192) {
          int length = int.parse(result.substring(64, 128), radix: 16);
          result = result.substring(128, 128 + length * 2);
          result = utf8.decoder.convert(hexToBytes(result));
          result = result.replaceAll(" ", "").trim();
          LogUtil.v("symbol  $result");
          object["symbol"] = result;
        }
      }
    }
    return object;
  }

  static Future<NFTIPFSInfo?> requestNFTInfo(
      {required KCoinType coinType, required dynamic qparams}) async {
    dynamic result = await requestDatas(coinType: coinType, params: qparams);
    if (result == null) {
      return null;
    }
    Map params = result as Map;
    if (params.keys.contains("result") && params["result"].length > 2) {
      String result = params["result"] as String;
      result = result.replaceAll("0x", "");
      if (result.length >= 192) {
        int length = int.parse(result.substring(64, 128), radix: 16);
        result = result.substring(128, 128 + length * 2);
        result = utf8.decoder.convert(hexToBytes(result));
        result = result.replaceAll(" ", "").trim();
        print("info  $result");
        return WalletServices.requestIPFSInfo(data: result);
      }
    }
  }
}
