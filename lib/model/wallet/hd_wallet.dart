import 'package:beewallet/model/chain/bsc.dart';

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

    if (kchainType == KChainType.ETH || kCoinType == KCoinType.BSC) {
      HDWallet ethWallet = (await BSCChain()
          .importWallet(content: content, pin: pin, kLeadType: kLeadType))!;
      if (kCoinType == null) {
        _hdwallets.add(ethWallet);
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
