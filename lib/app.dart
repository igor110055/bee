import 'package:beewallet/net/request_method.dart';
import 'package:beewallet/pages/tabbar/tabbar.dart';
import 'package:beewallet/public.dart';
import 'package:beewallet/state/wallet_state.dart';
import 'package:beewallet/utils/sp_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'component/custom_app.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:bip32/bip32.dart' as bip32;
import 'package:fixnum/fixnum.dart' as Fixnum;

import 'guide/guide_page.dart';

class MyApp extends StatefulWidget {
  //launch
  //tabbar
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final CurrentChooseWalletState _walletState = CurrentChooseWalletState();
  @override
  void initState() {
    super.initState();
    getSkip();
    _getLanguage();
  }

  void getSkip() async {
    _walletState.loadWallet();
  }

  void _getLanguage() {
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) async {
      if (SPManager.getAppLanguageMode() == KAppLanguage.system) {
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: const Size(428, 926),
        builder: () => MultiProvider(
                providers: [
                  ChangeNotifierProvider.value(value: _walletState),
                ],
                child: CustomApp(
                  child: GuidePage(),
                )));
    ;
  }
}
