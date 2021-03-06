import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:beewallet/const/constant.dart';
import 'package:beewallet/model/tokens/collection_tokens.dart';
import 'package:beewallet/model/transrecord/trans_record.dart';
import 'package:beewallet/net/chain_services.dart';
import 'package:beewallet/net/request_method.dart';
import 'package:beewallet/public.dart';
import 'package:beewallet/utils/custom_toast.dart';
import 'package:beewallet/utils/date_util.dart';
import 'package:beewallet/utils/encode.dart';
import 'package:beewallet/utils/extension.dart';
import 'package:beewallet/utils/json_util.dart';
import 'package:beewallet/utils/log_util.dart';
import 'package:decimal/decimal.dart';
import 'package:web3dart/contracts/erc20.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/json_rpc.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart' as web3;
import 'package:eth_sig_util/eth_sig_util.dart';

class SignTransactionClient {
  final Web3Client client;
  final int? _chainId;

  SignTransactionClient(String url, int chainId)
      : client = Web3Client(url, Client()),
        _chainId = chainId;

  Future<String?> transfer({
    required int coinType,
    required String prv,
    required MCollectionTokens token,
    required String amount,
    required String to,
    required bool isCustomfee,
    required String? data,
    required String? from,
    String? fee,
    int? gasPrice,
    int? maxGas,
    int? nonce,
    String? input,
  }) async {
    try {
      String? result;
      result = await _signEth(
          prv: prv,
          token: token,
          amount: amount,
          to: to,
          isCustomfee: isCustomfee,
          data: data,
          from: from,
          fee: fee,
          gasPrice: gasPrice,
          maxGas: maxGas,
          nonce: nonce,
          input: input);

      LogUtil.v("Transaction tx $result");
      if (result == null || result.isEmpty) {
        throw "交易失败";
      }
      TransRecordModel model = TransRecordModel();
      model.txid = result;
      model.amount = amount;
      model.fromAdd = from;
      model.date = DateUtil.getNowDateStr();
      model.token = token.token;
      model.coinType = token.coinType;
      model.fee = fee;
      model.gasPrice = gasPrice.toString();
      model.gasLimit = maxGas.toString();
      model.toAdd = to;
      model.transStatus = KTransState.pending.index;
      model.remarks = data;
      model.chainid = _chainId;
      // model.nonce = ts.nonce;
      // model.contractTo = ts.to?.hexEip55;
      // model.input = ts.data != null ? bytesToHex(ts.data!) : null;
      // model.signMessage = signMessage;
      model.repeatPushCount = 0;
      model.transType = KTransType.transfer.index;
      TransRecordModel.insertTrxLists([model]);
      return result;
    } catch (e) {
      LogUtil.v("transfer失败" + e.toString());
      if (e.toString().contains('-32000')) {
        HWToast.showText(text: "gasLow".local());
      } else {
        HWToast.showText(text: e.toString());
      }
    }
  }

  Future<String?> _signEth(
      {required String prv,
      required MCollectionTokens token,
      required String amount,
      required String to,
      required bool isCustomfee,
      required String? data,
      required String? from,
      required String? fee,
      required int? gasPrice,
      required int? maxGas,
      required int? nonce,
      required String? input}) async {
    final credentials = EthPrivateKey.fromHex(prv);
    Transaction? ts;
    if (token.isToken == false) {
      ts = web3.Transaction(
        to: EthereumAddress.fromHex(to),
        value: EtherAmount.inWei(amount.tokenInt(18)),
        gasPrice: gasPrice == null
            ? null
            : EtherAmount.fromUnitAndValue(EtherUnit.gwei, gasPrice),
        maxGas: isCustomfee == true ? maxGas : null,
        nonce: nonce ??
            await client.getTransactionCount(credentials.address,
                atBlock: const BlockNum.pending()),
        data: input != null
            ? hexToBytes(input)
            : Uint8List.fromList(utf8.encode(data ?? "")),
      );
    } else {
      EthereumAddress? contractAddress;
      DeployedContract? contract;
      ContractFunction? function;
      if (token.tokenType == KTokenType.token.index) {
        contractAddress = EthereumAddress.fromHex(token.contract!);
        contract = DeployedContract(_erc20Abi, contractAddress);
        function = contract.function('transfer');
        ts = web3.Transaction.callContract(
          contract: contract,
          function: function,
          parameters: [
            EthereumAddress.fromHex(to),
            amount.tokenInt(token.decimals!)
          ],
          gasPrice: gasPrice == null
              ? null
              : EtherAmount.fromUnitAndValue(EtherUnit.gwei, gasPrice),
          maxGas: isCustomfee == true ? maxGas : null,
          nonce: nonce ??
              await client.getTransactionCount(credentials.address,
                  atBlock: const BlockNum.pending()),
        );
      } else if (token.tokenType == KTokenType.eip721.index) {
        contractAddress = EthereumAddress.fromHex(token.contract!);
        contract = DeployedContract(_erc721Abi, contractAddress);
        function = contract.function('safeTransferFrom');
        ts = web3.Transaction.callContract(
          contract: contract,
          function: function,
          parameters: [
            EthereumAddress.fromHex(from!),
            EthereumAddress.fromHex(to),
            BigInt.parse(token.tid!),
            Uint8List.fromList(utf8.encode(data ?? ""))
          ],
          gasPrice: gasPrice == null
              ? null
              : EtherAmount.fromUnitAndValue(EtherUnit.gwei, gasPrice),
          maxGas: isCustomfee == true ? maxGas : null,
          nonce: nonce ??
              await client.getTransactionCount(credentials.address,
                  atBlock: const BlockNum.pending()),
        );
      } else if (token.tokenType == KTokenType.eip1155.index) {
        contractAddress = EthereumAddress.fromHex(token.contract!);
        contract = DeployedContract(_erc1155Abi, contractAddress);
        function = contract.function('safeTransferFrom');
        ts = web3.Transaction.callContract(
          contract: contract,
          function: function,
          parameters: [
            EthereumAddress.fromHex(from!),
            EthereumAddress.fromHex(to),
            BigInt.parse(token.tid!),
            BigInt.parse(amount),
            Uint8List.fromList(utf8.encode(data ?? ""))
          ],
          gasPrice: gasPrice == null
              ? null
              : EtherAmount.fromUnitAndValue(EtherUnit.gwei, gasPrice),
          maxGas: isCustomfee == true ? maxGas : null,
          nonce: nonce ??
              await client.getTransactionCount(credentials.address,
                  atBlock: const BlockNum.pending()),
        );
      }
    }
    Uint8List signedTransaction = await client.signTransaction(credentials, ts!,
        chainId: _chainId, fetchChainIdFromNetworkId: false);
    final signMessage = bytesToHex(signedTransaction, include0x: true);
    final result = await client.sendRawTransaction(signedTransaction);
    return result;
  }

  Future<String?> _signBtc({
    required String prv,
    required MCollectionTokens token,
    required String amount,
    required String to,
    required bool isCustomfee,
    required String? from,
    required String? fee,
    required int? gasPrice,
    required int? maxGas,
    required int? nonce,
    required String? input,
  }) async {}

  Future<String?> _signTRX({
    required String prv,
    required MCollectionTokens token,
    required String amount,
    required String to,
    required bool isCustomfee,
    required String? from,
    required String? fee,
    required int? gasPrice,
    required int? maxGas,
    required int? nonce,
    required String? input,
  }) async {}

  Future<String?> signPersonalMessage(String prv, String payload) async {
    final ethSigner = EthPrivateKey.fromHex(prv);
    Uint8List message =
        await ethSigner.signPersonalMessage(hexToBytes(payload));
    return bytesToHex(message, include0x: true);
  }

  Future<String?> transferOrigin({
    required String from,
    required String prv,
    required String to,
    required String data,
    required BigInt amount,
    int? gasLimit,
    String? gasPrice,
    String? fee,
    String? coinType,
  }) async {
    try {
      final credentials = EthPrivateKey.fromHex(prv);
      final signto = EthereumAddress.fromHex(to);
      final input = hexToBytes(data);
      String result = await client.sendTransaction(
          credentials,
          web3.Transaction(
              to: signto,
              value: EtherAmount.inWei(amount),
              gasPrice: null,
              maxGas: gasLimit,
              data: input),
          chainId: _chainId,
          fetchChainIdFromNetworkId: false);

      TransRecordModel model = TransRecordModel();
      model.txid = result;
      model.amount = amount.tokenString(18);
      model.fromAdd = from;
      model.date = DateUtil.getNowDateStr();
      model.token = coinType;
      model.coinType = coinType;
      model.fee = fee;
      model.gasPrice = gasPrice.toString();
      model.gasLimit = gasLimit.toString();
      model.toAdd = to;
      model.transStatus = KTransState.pending.index;
      model.chainid = _chainId;
      // model.nonce = ts.nonce;
      // model.contractTo = ts.to?.hexEip55;
      // model.input = ts.data != null ? bytesToHex(ts.data!) : null;
      // model.signMessage = signMessage;
      model.repeatPushCount = 0;
      model.transType = KTransType.transfer.index;
      TransRecordModel.insertTrxLists([model]);
      return result;
    } catch (e) {
      LogUtil.v("transfer失败" + e.toString());
      if (e.toString().contains('-32000')) {
        HWToast.showText(text: "gasLow".local());
      } else {
        HWToast.showText(text: e.toString());
      }
      return null;
    }
  }

  Future<String?> signTypedMessage(String prv, String jsonData) async {
    String signature = EthSigUtil.signTypedData(
        privateKey: prv, jsonData: jsonData, version: TypedDataVersion.V4);
    return signature;
  }

  Future<int> getGasPrice() async {
    EtherAmount gas = await this.client.getGasPrice();
    int value = gas.getValueInUnit(EtherUnit.gwei).toInt();
    return max(10, value);
  }

  Future<int?> estimateGas({
    String? from,
    String? to,
    String? value,
    EtherAmount? gasPrice,
    EtherAmount? maxPriorityFeePerGas,
    EtherAmount? maxFeePerGas,
    String? data,
  }) async {
    BigInt maxGas = BigInt.zero;
    maxGas = await this.client.estimateGas(
          sender: from != null ? EthereumAddress.fromHex(from) : null,
          to: to != null ? EthereumAddress.fromHex(to) : null,
          data: data != null ? hexToBytes(data) : null,
          value: value != null
              ? EtherAmount.fromUnitAndValue(EtherUnit.ether, value)
              : null,
        );
    return maxGas.toInt();
  }

  Future<TransactionReceipt?> getTransactionReceipt(String hash) {
    return this.client.getTransactionReceipt(hash);
  }

  Future<num> getBalance(String address) async {
    EtherAmount value =
        await this.client.getBalance(EthereumAddress.fromHex(address));
    return value.getValueInUnit(EtherUnit.ether);
  }

  Future<BigInt> getTokenBalance(String address, String contract) {
    final contractAddress = EthereumAddress.fromHex(contract);
    final erc20 = Erc20(address: contractAddress, client: this.client);
    return erc20.balanceOf(EthereumAddress.fromHex(address));
  }

  static String getEIP721Balance(String address, String contract) {
    final contractAddress = EthereumAddress.fromHex(contract);
    final dc = DeployedContract(_erc721Abi, contractAddress);
    final function = dc.function('balanceOf');
    return bytesToHex(function.encodeCall([EthereumAddress.fromHex(address)]),
        include0x: true);
  }

  static String getEIP1155Balance(String address, String contract, String tid) {
    final contractAddress = EthereumAddress.fromHex(contract);
    final dc = DeployedContract(_erc1155Abi, contractAddress);
    final function = dc.function('balanceOf');
    return bytesToHex(
        function.encodeCall([
          EthereumAddress.fromHex(address),
          BigInt.tryParse(tid) ?? BigInt.zero
        ]),
        include0x: true);
  }

  static Map get721TokenURI(String contract, String tid) {
    final contractAddress = EthereumAddress.fromHex(contract);
    final dc = DeployedContract(_erc721Abi, contractAddress);
    final function = dc.function('tokenURI');
    String data = bytesToHex(
        function.encodeCall([BigInt.tryParse(tid) ?? BigInt.zero]),
        include0x: true);
    return {
      "jsonrpc": "2.0",
      "id": tid,
      "method": "eth_call",
      "params": [
        {"to": contract, "data": data},
        "latest"
      ]
    };
  }

  int? get ChainID => _chainId;
}

final ContractAbi _erc20Abi = ContractAbi('ERC20', [
  const ContractFunction('approve', [
    FunctionParameter('to', AddressType()),
    FunctionParameter('amount', UintType(length: 256)),
  ]),
  const ContractFunction('transfer', [
    FunctionParameter('to', AddressType()),
    FunctionParameter('amount', UintType(length: 256)),
  ]),
  const ContractFunction(
      'allowance',
      [
        FunctionParameter('owner', AddressType()),
        FunctionParameter('spender', AddressType()),
      ],
      outputs: [FunctionParameter('', UintType(length: 256))],
      mutability: StateMutability.view)
], []);

final ContractAbi _erc721Abi = ContractAbi('ERC721', [
  const ContractFunction('safeTransferFrom', [
    FunctionParameter('from', AddressType()),
    FunctionParameter('to', AddressType()),
    FunctionParameter('id', UintType(length: 256)),
    FunctionParameter('data', DynamicBytes()),
  ]),
  const ContractFunction('tokenURI', [
    FunctionParameter('tokenId', UintType(length: 256)),
  ]),
  const ContractFunction('userAllTokens', [
    FunctionParameter('nftAddress', AddressType()),
    FunctionParameter('account', AddressType()),
  ]),
  const ContractFunction(
      'balanceOf', [FunctionParameter('from', AddressType())]),
], []);

final ContractAbi _erc1155Abi = ContractAbi('ERC721', [
  const ContractFunction('safeTransferFrom', [
    FunctionParameter('_from', AddressType()),
    FunctionParameter('_to', AddressType()),
    FunctionParameter('_id', UintType(length: 256)),
    FunctionParameter('_value', UintType(length: 256)),
    FunctionParameter('_data', DynamicBytes()),
  ]),
  const ContractFunction('balanceOf', [
    FunctionParameter('from', AddressType()),
    FunctionParameter('_id', UintType(length: 256)),
  ]),
], []);
