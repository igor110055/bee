import 'package:beewallet/model/chain/arb.dart';
import 'package:beewallet/model/chain/avax.dart';
import 'package:beewallet/model/chain/bsc.dart';
import 'package:beewallet/model/chain/eth.dart';
import 'package:beewallet/model/chain/heco.dart';
import 'package:beewallet/model/chain/matic.dart';
import 'package:beewallet/model/chain/okchain.dart';

import '../../public.dart';

class HDWallet {
  String? prv; //加密后的
  String? address; //地址
  String? pin; //pin
  String? content;
  KLeadType? leadType;
  KCoinType? coinType;
  HDWallet(
      {this.coinType,
      this.prv,
      this.address,
      this.pin,
      this.content,
      this.leadType});

  void toHDString() {
    // TODO: implement toString
    LogUtil.v(
        "HDWallet prv $prv , address $address pin $pin content $content leadType $leadType coinType $coinType");
  }

  HDWallet mutableCopy() {
    return HDWallet(
      prv: prv,
      address: address,
      pin: pin,
      content: content,
      leadType: leadType,
      coinType: coinType,
    );
  }

  static Future<List<HDWallet>> getHDWallet(
      {required String content,
      required String pin,
      required KLeadType kLeadType,
      required KChainType? kchainType,
      KCoinType? kCoinType}) async {
    List<HDWallet> _hdwallets = [];
    if (kLeadType == KLeadType.Memo || kLeadType == KLeadType.Restore) {
      kLeadType = KLeadType.Memo;
    }

    if (kchainType == KChainType.HD ||
        kchainType == KChainType.ETH ||
        kCoinType == KCoinType.ETH ||
        kCoinType == KCoinType.BSC ||
        kCoinType == KCoinType.HECO ||
        kCoinType == KCoinType.OKChain ||
        kCoinType == KCoinType.Matic ||
        kCoinType == KCoinType.AVAX ||
        kCoinType == KCoinType.Arbitrum) {
      HDWallet ethWallet = (await ETHChain()
          .importWallet(content: content, pin: pin, kLeadType: kLeadType))!;
      if (kCoinType == null) {
        _hdwallets.add(ethWallet);
        _hdwallets.add(ethWallet.mutableCopy()..coinType = KCoinType.BSC);
        _hdwallets.add(ethWallet.mutableCopy()..coinType = KCoinType.HECO);
        _hdwallets.add(ethWallet.mutableCopy()..coinType = KCoinType.OKChain);
        _hdwallets.add(ethWallet.mutableCopy()..coinType = KCoinType.Matic);
        _hdwallets.add(ethWallet.mutableCopy()..coinType = KCoinType.AVAX);
        _hdwallets.add(ethWallet.mutableCopy()..coinType = KCoinType.Arbitrum);
      } else {
        ethWallet.coinType = kCoinType;
        _hdwallets.add(ethWallet);
      }
    }

    return _hdwallets;
  }
}

abstract class HDWalletProtocol {
  Future<String> privateKeyFromMnemonic(String mnemonic);

  Future<String> privateKeyFromJson(String json, String password);

  Future<String> getPublicAddress(String privateKey);

  // String getPublicKey(String privateKey);

  Future<HDWallet?> importWallet(
      {required String content,
      required String pin,
      required KLeadType kLeadType});
}