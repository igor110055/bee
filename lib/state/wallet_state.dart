import 'dart:async';

import 'package:beewallet/component/chain_listtype.dart';
import 'package:beewallet/model/dapps_record/dapps_record.dart';
import 'package:beewallet/model/nft/nft_model.dart';
import 'package:beewallet/model/node/node_model.dart';
import 'package:beewallet/model/token_price/tokenprice.dart';
import 'package:beewallet/model/tokens/collection_tokens.dart';
import 'package:beewallet/model/transrecord/trans_record.dart';
import 'package:beewallet/model/wallet/tr_wallet.dart';
import 'package:beewallet/net/chain_services.dart';
import 'package:beewallet/net/wallet_services.dart';
import 'package:beewallet/pages/wallet/config_wallet_avatar.dart';
import 'package:beewallet/pages/wallet/transfer/receive_page.dart';
import 'package:beewallet/pages/wallet/transfer/transfer_list.dart';
import 'package:beewallet/pages/wallet/transfer/transfer_payment.dart';
import 'package:beewallet/pages/wallet/wallets/nft_listdata.dart';
import 'package:beewallet/pages/wallet/wallets/wallets_setting.dart';
import 'package:beewallet/utils/custom_toast.dart';
import 'package:beewallet/utils/sp_manager.dart';
import 'package:beewallet/utils/timer_util.dart';
import 'package:decimal/decimal.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/services.dart';
import '../public.dart';

class CurrentChooseWalletState with ChangeNotifier {
  TRWallet? _currentWallet;
  KCurrencyType? _currencyType;
  TRWallet? get currentWallet => _currentWallet;
  KCurrencyType? get currencyType => _currencyType;
  String get currencySymbolStr =>
      _currencyType == KCurrencyType.CNY ? "￥" : "\$";

  Map<String, Map> _nftIndexInfo = {};
  Map? get nftIndexInfo =>
      _currentWallet == null ? null : _nftIndexInfo[_currentWallet?.walletID];
  Map<String?, String> _totalTokenAssets = {}; //总资产数额
  Map<String?, String> _totalNFTAssets = {}; //总资产数额

  Map<String?, List<MCollectionTokens>> _tokens = {};
  List<MCollectionTokens> get tokens => _homeTokenType == 0
      ? _currentWallet == null
          ? []
          : (_tokens[_currentWallet?.walletID] ?? [])
      : nftInfos;

  KCoinType? _chooseChainType;
  String get chooseChain => _chooseChainType == null
      ? "walletmanager_asset_all".local()
      : _chooseChainType!.coinTypeString();

  TimerUtil? _timer;
  TimerUtil? _priceTimer;
  int _tokenIndex = 0;
  int _homeTokenType = 0;
  int get homeTokenType => _homeTokenType;
  Map<String?, List<NFTModel>> _nftContracts = {};
  List<NFTModel> get nftContracts => _currentWallet == null
      ? []
      : _nftContracts[_currentWallet?.walletID] ?? [];

  Map<String?, List<MCollectionTokens>> _nftInfos = {};
  List<MCollectionTokens> get nftInfos =>
      _currentWallet == null ? [] : _nftInfos[_currentWallet?.walletID] ?? [];

  List<KCoinType> _supportCoinTypes = [];
  List<KCoinType> get supportCoinTypes => _supportCoinTypes;

  MCollectionTokens? chooseTokens() {
    if (tokens.length > _tokenIndex) {
      return tokens[_tokenIndex];
    } else {
      LogUtil.v("chooseTokens越界");
      assert(false, "chooseTokens越界");
      return null;
    }
  }

  String? totalTokenAssets() {
    if (_currentWallet == null) {
      return "0.00";
    }
    if (_currentWallet!.hiddenAssets == true) {
      return "****";
    }
    return _totalTokenAssets[_currentWallet?.walletID] ?? "0.00";
  }

  String? totalNFTAssets() {
    if (_currentWallet == null) {
      return "0.00";
    }
    if (_currentWallet!.hiddenAssets == true) {
      return "****";
    }
    return _totalNFTAssets[_currentWallet?.walletID] ?? "0.00";
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    _priceTimer?.cancel();
    _priceTimer = null;
    super.dispose();
  }

  Future<TRWallet?> loadWallet() async {
    _chooseChainType = null;
    _tokenIndex = 0;
    _homeTokenType = 0;
    _currentWallet = await TRWallet.queryChooseWallet();
    _currencyType = SPManager.getAppCurrencyMode();
    requestAssets();
    // _configTimerRequest();
    notifyListeners();
    return _currentWallet;
  }

  ///定时任务请求
  void requestAssets() async {
    queryMyCollectionTokens();
    _requestMyCollectionTokenAssets();
    initNFTIndex();
    initNFTTokens();
  }

  void queryMyCollectionTokens() async {
    _currentWallet = await TRWallet.queryChooseWallet();
    if (_currentWallet == null) {
      return;
    }
    final String walletID = _currentWallet!.walletID!;
    List<MCollectionTokens> datas = [];
    KNetType netType = SPManager.getNetType();
    if (_chooseChainType == null) {
      datas =
          await MCollectionTokens.findStateTokens(walletID, 1, netType.index);
    } else {
      datas = await MCollectionTokens.findStateChainTokens(
          walletID, 1, netType.index, _chooseChainType!.index);
    }
    _tokens[walletID] = datas;
    _calTotalAssets();
  }

  void initNFTIndex() async {
    if (_currentWallet == null) {
      return;
    }
    String walletID = _currentWallet!.walletID!;
    KNetType netType = SPManager.getNetType();
    String? ethAdress;
    String? chainType;

    ethAdress = _currentWallet!.walletAaddress;
    chainType = _currentWallet!.coinType!.geCoinType().coinTypeString();
    if (ethAdress == null) {
      return;
    }
    Map? result = await WalletServices.getindexnftInfo(ethAdress, chainType);
    if (result == null) {
      return;
    }
    _nftIndexInfo[_currentWallet!.walletID!] = result;
    initNFTNetModel();
    notifyListeners();
  }

  void initNFTNetModel() async {
    if (_currentWallet == null) {
      return;
    }
    String walletID = _currentWallet!.walletID!;
    KNetType netType = SPManager.getNetType();
    String? ethAdress;
    String? chainType;

    ethAdress = _currentWallet!.walletAaddress;
    chainType = _currentWallet!.coinType!.geCoinType().coinTypeString();
    if (ethAdress == null) {
      return;
    }

    double usdtCny = 0.0;
    if (currencyType == KCurrencyType.CNY) {
      TokenPrice? priceModel =
          await TokenPrice.queryTokenPrices("USDT", KCurrencyType.CNY);
      if (priceModel != null) {
        usdtCny = double.parse(priceModel.rate ?? "0.0");
      }
    }
    List defaultNFT =
        await WalletServices.getUserNftList(address: ethAdress, pageNum: 1);
    for (var item in defaultNFT) {
      NFTModel nftModel = NFTModel.fromJson(item);
      nftModel.owner = walletID;
      nftModel.kNetType = netType.index;
      String tokenID = nftModel.createTokenID(walletID);
      nftModel.tokenID = tokenID;
      double p = double.tryParse((nftModel.usdtValues ?? "0.0")) ?? 0.0;
      if (currencyType == KCurrencyType.CNY) {
        nftModel.usdtValues = (p * usdtCny).toStringAsFixed(2);
      }
      List<NFTModel> dbs =
          await NFTModel.findNFTBySQL('"tokenID" = \'$tokenID\'');
      if (dbs.isEmpty) {
        nftModel.state = 1;
        NFTModel.insertTokens([nftModel]);
      } else {
        NFTModel dbModel = dbs.first;
        dbModel.chainTypeName = nftModel.chainTypeName;
        dbModel.contractName = nftModel.contractName;
        dbModel.usdtValues = nftModel.usdtValues;
        dbModel.nftTypeName = nftModel.nftTypeName;
        dbModel.contractAddress = nftModel.contractAddress;
        dbModel.url = nftModel.url;
        dbModel.nftId = nftModel.nftId;
        NFTModel.updateTokens(dbModel);
      }
    }
    notifyListeners();
  }

  void userNftProjectIds(NFTModel nftModel) async {
    if (_currentWallet == null) {
      return;
    }
    String walletID = _currentWallet!.walletID!;
    KNetType netType = SPManager.getNetType();
    String? ethAdress;
    String? chainType;

    ethAdress = _currentWallet!.walletAaddress;
    chainType = _currentWallet!.coinType!.geCoinType().coinTypeString();
    if (ethAdress == null) {
      return;
    }
    String contractAddress = nftModel.contractAddress ?? '';
    List result =
        await WalletServices.userNftProjectIds(contractAddress, ethAdress);
    if (result.isEmpty) {
      return;
    }
    nftModel.nftId = result.join(",");
    NFTModel.updateTokens(nftModel);
    initNFTTokensList(nftModel);

    // List defaultNFT =
    //     await WalletServices.getUserNftList(address: ethAdress, pageNum: 1);
    // for (var item in defaultNFT) {
    //   NFTModel nftModel = NFTModel.fromJson(item);
    //   nftModel.owner = walletID;
    //   nftModel.kNetType = netType.index;
    //   String tokenID = nftModel.createTokenID(walletID);
    //   nftModel.tokenID = tokenID;
    //   List<NFTModel> dbs = await NFTModel.findNFTBySQL('"tokenID" = \'$tokenID\'');
    //   if (dbs.isEmpty) {
    //     nftModel.state = 1;
    //     NFTModel.insertTokens([nftModel]);
    //   } else {
    //     NFTModel dbModel = dbs.first;
    //     dbModel.chainTypeName = nftModel.chainTypeName;
    //     dbModel.contractName = nftModel.contractName;
    //     dbModel.usdtValues = nftModel.usdtValues;
    //     dbModel.nftTypeName = nftModel.nftTypeName;
    //     dbModel.contractAddress = nftModel.contractAddress;
    //     dbModel.url = nftModel.url;
    //     dbModel.nftId = nftModel.nftId;
    //     NFTModel.updateTokens(dbModel);
    //   }
    // }
  }

  void initNFTTokens() async {
    if (_currentWallet == null) {
      return;
    }
    List<NFTModel> nftModels = [];
    final String walletID = _currentWallet!.walletID!;
    KNetType netType = SPManager.getNetType();
    if (_chooseChainType == null) {
      nftModels = await NFTModel.findStateTokens(walletID, 1, netType.index);
    } else {
      nftModels = await NFTModel.findStateChainTokens(walletID, 1,
          netType.index, _chooseChainType!.coinTypeString().toLowerCase());
    }
    _nftContracts[_currentWallet!.walletID!] = nftModels;
    notifyListeners();
  }

  void updateCurrencyType(KCurrencyType kCurrencyType) {
    _currencyType = kCurrencyType;
    SPManager.setAppCurrency(kCurrencyType);
    LogUtil.v("updateCurrencyType $kCurrencyType");
    requestAssets();
  }

  ///选择链类型
  void onTapChain(
      BuildContext context, List<KCoinType> coins, Function(KCoinType) onTap) {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (_) {
          return ChainListType(
            onTap: onTap,
            datas: coins,
          );
        });
  }

  void setDeviceLocale(BuildContext context) {
    Locale first = context.deviceLocale;
    for (var element in context.supportedLocales) {
      if (element.languageCode.contains(first.languageCode)) {
        LogUtil.v("element " + element.languageCode);
        context.setLocale(element);
        SPManager.setSystemAppLanguage(element.languageCode == "zh"
            ? KAppLanguage.zh_cn
            : KAppLanguage.en_us);
      }
    }
  }

  void assetsHidden(BuildContext context) async {
    LogUtil.v("assetsHidden");
    if (_currentWallet == null) {
      return;
    }
    _currentWallet =
        await TRWallet.queryWalletByWalletID(_currentWallet!.walletID!);
    _currentWallet!.hiddenAssets = (_currentWallet!.hiddenAssets == null ||
            _currentWallet!.hiddenAssets == false)
        ? true
        : false;
    TRWallet.updateWallet(_currentWallet!);
    notifyListeners();
  }

  void tapHelper(BuildContext context, KCoinType? coinType) {
    LogUtil.v("_tapHelper");
    if (_currentWallet == null) {
      return;
    }
    _chooseChainType = coinType;
    queryMyCollectionTokens();
    initNFTTokens();
  }

  void tapWalletSetting(BuildContext context) {
    LogUtil.v("assetsHidden");
    if (_currentWallet == null) {
      HWToast.showText(text: "minepage_pleasecreate".local());
      return;
    }
    Routers.push(context, WalletsSetting(wallet: _currentWallet!));
  }

  void tapNFTInfo(BuildContext context, NFTModel nftInfo) {
    initNFTTokensList(nftInfo);
    Routers.push(context, NFTListData(model: nftInfo));
  }

  void initNFTTokensList(NFTModel nftInfo) {
    List datas = [];
    if (nftInfo.nftId!.isNotEmpty) {
      datas = nftInfo.nftId!.split(",");
    }
    String chainTypeName = nftInfo.chainTypeName ?? "";
    String contractAddress = nftInfo.contractAddress ?? "";
    final String walletID = _currentWallet!.walletID!;
    String url = nftInfo.url ?? "";
    List<MCollectionTokens> _datas = [];
    for (var item in datas) {
      KCoinType coinType = chainTypeName.chainTypeGetCoinType()!;
      MCollectionTokens model = MCollectionTokens();
      model.contract = contractAddress;
      model.digits = 0;
      model.chainType = coinType.index;
      model.tid = item.toString();
      model.iconPath = url;
      model.decimals = 0;
      model.token = "";
      model.tokenType = KTokenType.eip721.index;
      model.balance = 0.0;
      model.coinType = chainTypeName.chainTypeGetCoinType()!.coinTypeString();
      model.tokenID = model.createTokenID(walletID);
      _datas.add(model);
    }
    _nftInfos[walletID] = _datas;
    notifyListeners();
  }

  void onIndexChanged(BuildContext context, int index) {
    _homeTokenType = index;
    if (index == 1) {
      initNFTTokens();
    }
    notifyListeners();
  }

  Future<bool> updateChoose(BuildContext context,
      {required TRWallet wallet}) async {
    List<TRWallet> wallets = await TRWallet.queryAllWallets();
    for (var item in wallets) {
      item.isChoose = false;
      if (wallet.walletID == item.walletID) {
        item.isChoose = true;
        _currentWallet = item;
      }
    }
    _chooseChainType = null;
    _tokenIndex = 0;
    TRWallet.updateWallets(wallets);
    initNFTIndex();
    initNFTTokens();
    requestAssets();

    notifyListeners();
    return true;
  }

  void updateTokenChoose(BuildContext context, int index,
      {bool pushTransList = false,
      bool pushPayments = false,
      bool pushReceive = false}) async {
    _tokenIndex = index;
    final String walletID = _currentWallet!.walletID!;

    if (pushTransList == true) {
      Routers.push(context, TransferListPage());
      return;
    }
    if (pushPayments == true) {
      Routers.push(context, TransferPayment());
      return;
    }
    if (pushReceive == true) {
      Routers.push(context, RecervePaymentPage());
    }
  }

  void walletcellTapReceive(BuildContext context, int index,
      {bool tapNFT = false}) async {
    if (tapNFT == false) {
      updateTokenChoose(context, index, pushReceive: true);
    } else {
      final String walletID = _currentWallet!.walletID!;
      String chainType = nftContracts[index].chainTypeName ?? "";
      Routers.push(context, RecervePaymentPage());
    }
  }

  void deleteWallet(BuildContext context, {required TRWallet wallet}) {
    wallet.showLockPin(context, exportPrv: false,
        confirmPressed: (value) async {
      bool flag = await TRWallet.deleteWallet(wallet);
      if (flag) {
        TRWallet? wallet = await TRWallet.queryChooseWallet();
        if (wallet == null) {
          List<TRWallet> wallets = await TRWallet.queryAllWallets();
          if (wallets.isNotEmpty) {
            wallet = wallets.first;
            wallet.isChoose = true;
            await updateChoose(context, wallet: wallet);
            HWToast.showText(text: "wallet_delwallet".local());
            Future.delayed(Duration(seconds: 2)).then((value) => {
                  Routers.goBackWithParams(context, {}),
                });
          } else {
            _currentWallet = null;
            notifyListeners();
            HWToast.showText(text: "wallet_delwallet".local());
            Routers.goBack(context);
          }
        }
      }
    }, cancelPress: null, infoCoinType: null);
  }

  void exportPrv(BuildContext context, {required TRWallet wallet}) {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (_) {
          return ChainListType(
            onTap: (KCoinType coinType) {
              wallet.showLockPin(context, infoCoinType: coinType,
                  confirmPressed: (value) {
                ShowCustomAlert.showCustomAlertType(context, KAlertType.text,
                    "walletssetting_exportprv".local(), wallet,
                    hideLeftButton: true,
                    bottomActionsPadding:
                        EdgeInsets.fromLTRB(16.width, 0, 16.width, 16.width),
                    rightButtonBGC: ColorUtils.blueColor,
                    rightButtonRadius: 8,
                    rightButtonTitle: "dialog_copy".local(),
                    subtitleText: value, confirmPressed: (result) {
                  String text = result["text"] ?? '';
                  text.copy();
                });
              }, cancelPress: () {});
            },
            datas: [],
          );
        });
  }

  void backupWallet(BuildContext context, {required TRWallet wallet}) {
    // wallet.showLockPin(context, exportPrv: false, confirmPressed: (value) {
    //   Routers.push(
    //       context, BackupTipMemo(memo: value, walletID: wallet.walletID!));
    // }, cancelPress: null, infoCoinType: null);
  }

  void modifyPwd(BuildContext context,
      {required TRWallet wallet,
      required String oldPin,
      required String newPin,
      required String againPin,
      required String pinTip}) {
    if (oldPin.length == 0 || newPin.length == 0 || againPin.length == 0) {
      HWToast.showText(text: "input_pwd".local());
      return;
    }
    if (newPin != againPin) {
      HWToast.showText(text: "input_pwd_wrong".local());
      return;
    }
    if (newPin.checkPassword() == false) {
      HWToast.showText(text: "input_pwd_regexp".local());
      return;
    }
    wallet.lockPin(
        text: oldPin,
        ok: (value) {
          //旧的解密
          //新的将私钥助记词加密
          final content = wallet.exportEncContent(pin: oldPin);
          wallet.pin = TREncode.SHA256(newPin);
          wallet.encContent = TREncode.encrypt(content!, newPin);
          wallet.pinTip = pinTip;
          TRWallet.updateWallet(wallet);
          HWToast.showText(text: "dialog_modifyok".local());
          Future.delayed(Duration(seconds: 2)).then((value) => {
                Routers.goBack(context),
              });
        },
        wrong: () {
          HWToast.showText(text: "dialog_wrongpin".local());
        });
  }

  void _requestMyCollectionTokenAssets() async {
    _currentWallet = await TRWallet.queryChooseWallet();
    if (_currentWallet == null) {
      return;
    }
    String walletAaddress = _currentWallet!.walletAaddress!;
    for (int i = 0; i < tokens.length; i++) {
      MCollectionTokens map = tokens[i];
      map.balanceOf(walletAaddress, currencyType ?? KCurrencyType.CNY);
    }
  }

  void _configTimerRequest() async {
    if (_timer == null) {
      _timer = TimerUtil(mInterval: 5000);
      _timer!.setOnTimerTickCallback((millisUntilFinished) async {
        if (_currentWallet == null) return;
        requestAssets();
      });
    }
    if (_timer!.isActive() == false) {
      _timer!.startTimer();
    }
    if (_priceTimer == null) {
      _priceTimer = TimerUtil(mInterval: 30000);
      _priceTimer!.setOnTimerTickCallback((millisUntilFinished) async {
        if (_currentWallet == null) return;
        Set<String> token = Set();
        token.addAll(tokens.map((e) => e.token!).toList());
        if (token.isEmpty) {
          return;
        }
        token.add("usdt");
        WalletServices.gettokenPrice(token.join(","));
      });
    }
    if (_priceTimer!.isActive() == false) {
      _priceTimer!.startTimer();
    }
  }

  ///计算我的总资产
  void _calTotalAssets() {
    final String? walletID = _currentWallet!.walletID;
    Decimal sumAssets = Decimal.zero;
    List<MCollectionTokens> userTokens = _tokens[walletID] ?? [];
    for (int i = 0; i < userTokens.length; i++) {
      MCollectionTokens map = userTokens[i];
      sumAssets += Decimal.tryParse(map.assets) ?? Decimal.zero;
    }
    String total = sumAssets == Decimal.zero ? "0.00" : sumAssets.toString();
    _totalTokenAssets[walletID] = total;

    Decimal sumnftAssets = Decimal.zero;

    List<NFTModel> userNFTTokens = _nftContracts[walletID] ?? [];
    for (int i = 0; i < userNFTTokens.length; i++) {
      NFTModel map = userNFTTokens[i];
      sumnftAssets += Decimal.tryParse(map.assets()) ?? Decimal.zero;
    }
    String totalnft =
        sumnftAssets == Decimal.zero ? "0.00" : sumnftAssets.toString();
    _totalNFTAssets[walletID] = totalnft;
    notifyListeners();
  }
}
