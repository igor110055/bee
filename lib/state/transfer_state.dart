import 'package:beewallet/model/client/sign_client.dart';
import 'package:beewallet/model/node/node_model.dart';
import 'package:beewallet/model/tokens/collection_tokens.dart';
import 'package:beewallet/net/wallet_services.dart';
import 'package:beewallet/pages/mine/mine_contacts.dart';
import 'package:beewallet/pages/wallet/transfer/payment_sheet_page.dart';
import 'package:beewallet/pages/wallet/transfer/transfer_fee.dart';
import 'package:beewallet/utils/custom_toast.dart';
import 'package:decimal/decimal.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';
import '../public.dart';

class KTransferState with ChangeNotifier {
  TextEditingController _addressEC = TextEditingController();
  TextEditingController _valueEC = TextEditingController();
  TextEditingController _remarkEC = TextEditingController();

  TextEditingController get addressEC => _addressEC;
  TextEditingController get valueEC => _valueEC;
  TextEditingController get remarkEC => _remarkEC;

  TRWallet? _wallet;
  TRWallet? get wallet => _wallet;
  SignTransactionClient? _client;
  MCollectionTokens? _tokens;

  String _gasLimit = '';
  String _feeOffset = "20"; //gas or sat
  String _feeValue = '0.0';
  bool _isCustomFee = false;
  int _seleindex = 1;
  String _paymentAssets = "--";
  String get paymentAssets => _paymentAssets;
  String? _currencySymbolStr;
  final double _sliderMin = 6;
  final double _sliderMax = 135;
  double get sliderMin => _sliderMin;
  double get sliderMax => _sliderMax;
  String get feeOffset => _feeOffset;

  String feeValue() {
    if (_tokens == null) {
      return _feeValue + "";
    }
    return _feeValue + " " + _wallet!.coinType!.geCoinType().feeTokenString();
  }

  void sliderChange(double value) {
    _feeOffset = value.toInt().toString();
    String fee = TRWallet.configFeeValue(
        cointype: _wallet!.coinType!,
        beanValue: _gasLimit,
        offsetValue: _feeOffset);
    _feeValue = fee;
    notifyListeners();
  }

  void init(BuildContext context) {
    _wallet = Provider.of<CurrentChooseWalletState>(context, listen: false)
        .currentWallet!;
    _tokens = Provider.of<CurrentChooseWalletState>(context, listen: false)
        .chooseTokens()!;
    _currencySymbolStr =
        Provider.of<CurrentChooseWalletState>(context, listen: false)
            .currencySymbolStr;
    NodeModel node = NodeModel.queryNodeByChainType(_wallet!.coinType!);
    if (node.content == null) {
      return;
    }
    _valueEC.addListener(() async {
      String text = _valueEC.text;
      if (text.isEmpty) {
        text = "0";
      }
      Decimal tokenPrice = Decimal.parse(_tokens!.priceString);
      Decimal inputValue = Decimal.parse(text);
      Decimal assets = tokenPrice * inputValue;
      _paymentAssets = "???" + _currencySymbolStr! + assets.toStringAsFixed(2);
      notifyListeners();
    });
    _client = SignTransactionClient(node.content!, node.chainID!);
    if (inProduction == false) {
      _addressEC.text = "TBT69QcL1j9FrXDdQh8rbzKbciUA1Lq9AF";
    }
    notifyListeners();
    initGasData();
  }

  @override
  void dispose() {
    _valueEC.removeListener(() {});
    super.dispose();
  }

  void initGasData() async {
    dynamic result = await WalletServices.getgasPrice(_tokens!.coinType!);
    if (result == null) {
      return;
    }
    Decimal offset = Decimal.fromInt(10).pow(9);
    String fastgas = result!["gasNormalPrice"];
    fastgas = (Decimal.parse(fastgas) / offset).toDecimal().toString();
    if (_tokens!.tokenType == KTokenType.native.index) {
      _gasLimit = transferETHGasLimit.toString();
    } else {
      _gasLimit = transferERC20GasLimit.toString();
    }
    _feeOffset = fastgas;

    String fee = TRWallet.configFeeValue(
        cointype: _wallet!.coinType!,
        beanValue: _gasLimit,
        offsetValue: _feeOffset);
    _feeValue = fee;
    notifyListeners();
  }

  void goContract(BuildContext context) async {
    Map result = await Routers.push(context, MineContacts(type: 0));
    if (result != null) {
      final text = result["text"] ?? "";
      _addressEC.text = text;
    }
  }

  void tapBalanceAll(BuildContext context) {
    LogUtil.v("tapBalanceAll");
  }

  void tapFeeView(BuildContext context) {
    LogUtil.v("tapFeeView");
    Routers.push(
        context,
        TransfeeView(
          feeValue: _feeValue,
          gasLimit: _gasLimit,
          gasPrice: _feeOffset,
          complationBack: (feeValue, gasPrice, gasLimit, isCustom, seleindex) {
            LogUtil.v("feeValue $feeValue $gasPrice $gasLimit $isCustom");
            _feeValue = feeValue;
            _feeOffset = gasPrice;
            _gasLimit = gasLimit;
            _isCustomFee = _isCustomFee;
            _seleindex = seleindex;
            notifyListeners();
          },
          feeToken: _wallet!.coinType!.geCoinType().feeTokenString(),
          chaintype: _tokens!.coinType!,
          seleindex: _seleindex,
        ));
  }

  void tapTransfer(BuildContext context) async {
    LogUtil.v(
        "popupInfo gasPrice $_feeOffset gasLimit $_gasLimit feeValue $_feeValue iscustom $_isCustomFee");
    FocusScope.of(context).requestFocus(FocusNode());
    HWToast.showLoading();
    bool isToken = _tokens!.isToken;
    int decimals = _tokens!.decimals ?? 0;
    String from = _wallet!.walletAaddress!;
    String to = _addressEC.text.trim();
    String amount = _valueEC.text.trim();
    if (_tokens?.tokenType == KTokenType.eip721.index) {
      amount = "1";
    }
    String remark = _remarkEC.text.trim();
    bool? isValid = false;
    int coinType = _wallet!.coinType!;
    String feeToken = coinType.geCoinType().feeTokenString();
    isValid = await to.checkAddress(coinType.geCoinType());
    if (isValid == false) {
      HWToast.showText(text: "input_addressinvalid".local());
      return;
    }
    if (amount.isEmpty) {
      HWToast.showText(text: "input_paymentvalue".local());
      return;
    }
    BigInt amountBig = amount.tokenInt(decimals);
    BigInt balanceBig = _tokens!.balanceString.tokenInt(decimals);
    if (amountBig > balanceBig) {
      HWToast.showText(text: "payment_valueshouldlessbal".local());
      return;
    }

    //trx ?????????????????????
    if (_feeValue == null || _feeValue.isEmpty == true) {
      _feeValue = TRWallet.configFeeValue(
          cointype: coinType, beanValue: _gasLimit, offsetValue: _feeOffset);
    } else {
      _feeValue = _feeValue
          .trim()
          .replaceAll("ETH", "")
          .replaceAll(_tokens!.token!, "")
          .replaceAll(" ", "");
    }
    if (double.parse(_feeValue) == 0) {
      HWToast.showText(text: "payment_highfee".local());
      return;
    }
    BigInt feeBig = BigInt.zero;
    feeBig = _feeValue.tokenInt(18);

    if (isToken == true) {
      num mainBalance = await _client!.getBalance(from);
      BigInt mainTokenBig = mainBalance.toString().tokenInt(18);
      if (feeBig > mainTokenBig) {
        HWToast.showText(text: "paymenttip_ethnotenough".local());
        return;
      }
    } else {
      if (balanceBig == amountBig) {
        amountBig = balanceBig - feeBig;
      }
      if (feeBig + amountBig > balanceBig) {
        HWToast.showText(text: "paymenttip_ethnotenough".local());
        return;
      }
    }

    if (amountBig.compareTo(BigInt.zero) <= 0) {
      HWToast.showText(text: "input_paymentvaluezero".local());
      return;
    }
    HWToast.hiddenAllToast();
    _showSheetView(
      context,
      amount: amountBig.tokenString(decimals),
      remark: remark,
      to: to,
      from: from,
      feeToken: feeToken,
    );
  }

  ///??????????????????????????????????????????
  void _showSheetView(
    BuildContext context, {
    required String from,
    required String to,
    required String amount,
    required String remark,
    required String feeToken,
  }) async {
    showModalBottomSheet(
        context: context,
        elevation: 0,
        isDismissible: true,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        )),
        builder: (_) {
          return PaymentSheet(
            datas: PaymentSheet.getTransStyleList(
                from: from,
                to: to,
                remark: remark,
                fee: _feeValue + feeToken,
                hiddenFee: false),
            amount: amount + " ${_tokens!.token!}",
            nextAction: () {
              _wallet!.showLockPin(context,
                  infoCoinType: _wallet!.coinType!.geCoinType(),
                  confirmPressed: (value) {
                _startSign(
                  context,
                  from: from,
                  to: to,
                  amount: amount,
                  remark: remark,
                  prv: value,
                );
              }, cancelPress: null);
            },
            cancelAction: () {},
          );
        });
  }

  ///????????????
  void _startSign(
    BuildContext context, {
    required String prv,
    required String from,
    required String to,
    required String amount,
    required String remark,
  }) async {
    HWToast.showLoading(clickClose: true);
    int? maxGas = Decimal.tryParse(_gasLimit)?.toBigInt().toInt();
    int? gasPrice = Decimal.tryParse(_feeOffset)?.toBigInt().toInt();
    String? result;
    result = await _client!.transfer(
        coinType: _wallet!.coinType!,
        prv: prv,
        token: _tokens!,
        amount: amount,
        to: to,
        isCustomfee: _isCustomFee,
        data: remark,
        from: from,
        fee: _feeValue,
        maxGas: maxGas,
        gasPrice: gasPrice);

    if (result?.isNotEmpty == true) {
      HWToast.showText(text: "payment_transsuccess".local());
      Future.delayed(Duration(seconds: 1)).then((value) => {
            Routers.goBackWithParams(context, {}),
          });
    }
  }
}
