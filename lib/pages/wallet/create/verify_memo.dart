import 'dart:math';

import 'package:beewallet/component/sortindex_button.dart';
import 'package:beewallet/component/sortindex_view.dart';
import 'package:beewallet/model/wallet/tr_wallet.dart';
import 'package:beewallet/pages/tabbar/tabbar.dart';
import 'package:beewallet/utils/custom_toast.dart';
import 'package:beewallet/utils/extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../../public.dart';

class VerifyMemo extends StatefulWidget {
  const VerifyMemo({Key? key, required this.memo, required this.walletID})
      : super(key: key);
  final String memo;
  final String walletID;

  @override
  State<VerifyMemo> createState() => _VerifyMemoState();
}

class _VerifyMemoState extends State<VerifyMemo> {
  List<SortViewItem> _bottomList = [];
  List<String> _originList = [];
  bool _isHWrong = true;

  TextEditingController _word01EC = TextEditingController();
  TextEditingController _word02EC = TextEditingController();
  TextEditingController _word03EC = TextEditingController();
  bool _word01err = false;
  bool _word02err = false;
  bool _word03err = false;

  List<int> _randomDatas = [];

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() {
    List<String> memos = widget.memo.split(" ");
    LogUtil.v(memos);
    setState(() {
      _randomDatas = getRandromList(3, 12);
      for (var i = 0; i < memos.length; i++) {
        final value = memos[i];
        _originList.add(value);
      }
      memos.shuffle(Random());
      for (var i = 0; i < memos.length; i++) {
        final value = memos[i];
        final item = SortViewItem(value: value, index: i, select: false);
        _bottomList.add(item);
      }
    });

    _word01EC.addListener(() {
      var text = _word01EC.text;
      bool status = false;
      if (text.isEmpty) {
        status = false;
      } else {
        status = text == _originList[_randomDatas[0] - 1] ? false : true;
      }
      setState(() {
        _word01err = status;
      });
      _checkNextSatus();
    });
    _word02EC.addListener(() {
      var text = _word02EC.text;
      bool status = false;
      if (text.isEmpty) {
        status = false;
      } else {
        status = text == _originList[_randomDatas[1] - 1] ? false : true;
      }
      setState(() {
        _word02err = status;
      });
      _checkNextSatus();
    });
    _word03EC.addListener(() {
      var text = _word03EC.text;
      bool status = false;
      if (text.isEmpty) {
        status = false;
      } else {
        status = text == _originList[_randomDatas[2] - 1] ? false : true;
      }
      setState(() {
        _word03err = status;
      });
      _checkNextSatus();
    });
  }

  void _checkNextSatus() {
    bool status = true;
    if (_word01err == false && _word02err == false && _word03err == false) {
      status = false;
    }
    if (_word01EC.text.isEmpty ||
        _word02EC.text.isEmpty ||
        _word03EC.text.isEmpty) {
      status = true;
    }

    setState(() {
      _isHWrong = status;
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _word01EC.removeListener(() {});
    _word02EC.removeListener(() {});
    _word03EC.removeListener(() {});

    super.dispose();
  }

  void _verifyAction() async {
    if (_isHWrong == true) {
      HWToast.showText(text: "verifymemo_havewrong".local());
      return;
    }

    //TRWallet.importWallet(context, content: content, pin: pin, pinAgain: pinAgain, pinTip: pinTip, walletName: walletName, kChainType: kChainType, kLeadType: kLeadType)

    // TRWallet? trWallet = await TRWallet.queryWalletByWalletID(widget.walletID);
    // if (trWallet != null) {
    //   trWallet.accountState = KAccountState.authed.index;
    //   TRWallet.updateWallet(trWallet);
    //   HWToast.showText(text: "verifymemo_backupcomplation".local());
    //   Future.delayed(const Duration(milliseconds: 1500)).then((value) => {
    //         Routers.push(context, HomeTabbar(), clearStack: true),
    //       });
    // }
  }

  void _bottomListAction(int index) {
    LogUtil.v("_bottomListAction $index");
    SortViewItem bottomItem = _bottomList[index];
    var text = bottomItem.value;
    if (bottomItem.select == true) {
      bottomItem.select = false;
      setState(() {
        _bottomList.replaceRange(index, index + 1, [bottomItem]);
      });
      if (_word01EC.text == text) {
        _word01EC.clear();
        return;
      }
      if (_word02EC.text == text) {
        _word02EC.clear();
        return;
      }
      if (_word03EC.text == text) {
        _word03EC.clear();
        return;
      }
      return;
    }
    int maxCount = _bottomList.where((e) => e.select == true).toList().length;
    if (maxCount == 3) {
      return;
    }
    bottomItem.select = true;
    setState(() {
      _bottomList.replaceRange(index, index + 1, [bottomItem]);
    });
    if (_word01EC.text.isEmpty) {
      _word01EC.text = text;
      return;
    }
    if (_word02EC.text.isEmpty) {
      _word02EC.text = text;
      return;
    }
    if (_word03EC.text.isEmpty) {
      _word03EC.text = text;
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomPageView(
      child: Container(
        padding: EdgeInsets.fromLTRB(24.width, 0, 24.width, 24.width),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "backup_pleaseverify".local(),
                        style: TextStyle(
                          fontSize: 28.font,
                          fontWeight: FontWeightUtils.bold,
                          color: ColorUtils.FF363B3E,
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.only(top: 16.width),
                      child: Text(
                        "backup_pleaseselect".local(),
                        style: TextStyle(
                          fontSize: 16.font,
                          fontWeight: FontWeightUtils.regular,
                          color: ColorUtils.FF8F9397,
                        ),
                      ),
                    ),
                    CustomTextField.getInputTextField(context,
                        padding: EdgeInsets.only(top: 16.width),
                        controller: _word01EC,
                        titleText: "Word#" + _randomDatas[0].toString(),
                        enabled: false,
                        errText: _word01err == true
                            ? "importwallet_hint04".local()
                            : null,
                        errTextStyle: TextStyle(
                          fontSize: 14.font,
                          color: ColorUtils.fromHex("#FFFF606B"),
                        ),
                        hintText: "input_putchar".local(
                            namedArgs: {"index": _randomDatas[0].toString()})),
                    CustomTextField.getInputTextField(context,
                        padding: EdgeInsets.only(top: 10.width),
                        controller: _word02EC,
                        enabled: false,
                        titleText: "Word#" + _randomDatas[1].toString(),
                        errText: _word02err == true
                            ? "importwallet_hint04".local()
                            : null,
                        errTextStyle: TextStyle(
                          fontSize: 14.font,
                          color: ColorUtils.fromHex("#FFFF606B"),
                        ),
                        hintText: "input_putchar".local(
                            namedArgs: {"index": _randomDatas[1].toString()})),
                    CustomTextField.getInputTextField(context,
                        padding:
                            EdgeInsets.only(top: 10.width, bottom: 0.width),
                        controller: _word03EC,
                        enabled: false,
                        errText: _word03err == true
                            ? "importwallet_hint04".local()
                            : null,
                        errTextStyle: TextStyle(
                          fontSize: 14.font,
                          color: ColorUtils.fromHex("#FFFF606B"),
                        ),
                        titleText: "Word#" + _randomDatas[2].toString(),
                        hintText: "input_putchar".local(
                            namedArgs: {"index": _randomDatas[2].toString()})),
                    SortIndexView(
                      memos: _bottomList,
                      margin: EdgeInsets.only(top: 4.width),
                      offsetWidth: 50.width,
                      bgColor: Colors.white,
                      type: SortIndexType.actionIndex,
                      onTap: (int index) {
                        _bottomListAction(index);
                      },
                    ),
                  ],
                ),
              ),
            ),
            NextButton(
              onPressed: () {
                _verifyAction();
              },
              enabled: !_isHWrong,
              title: "button_next".local(),
            ),
          ],
        ),
      ),
    );
  }
}
