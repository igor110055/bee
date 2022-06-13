import 'package:beewallet/component/sortindex_button.dart';
import 'package:beewallet/component/sortindex_view.dart';
import 'package:beewallet/pages/tabbar/tabbar.dart';
import 'package:beewallet/pages/wallet/create/verify_memo.dart';
import 'package:beewallet/utils/custom_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../public.dart';

class BackupMemo extends StatefulWidget {
  const BackupMemo({Key? key, required this.memo, required this.walletID})
      : super(key: key);
  final String memo;
  final String walletID;

  @override
  State<BackupMemo> createState() => _BackupMemoState();
}

class _BackupMemoState extends State<BackupMemo> {
  List<SortViewItem> _datas = [];

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() {
    List<String> memos = widget.memo.split(" ");
    setState(() {
      for (var i = 0; i < memos.length; i++) {
        final value = memos[i];
        final item = SortViewItem(value: value, index: i);
        _datas.add(item);
      }
    });
  }

  void _backMemo() {
    Routers.push(
        context, VerifyMemo(memo: widget.memo, walletID: widget.walletID));
  }

  void _copyMemo() {
    widget.memo.copy();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPageView(
      child: Container(
        padding: EdgeInsets.all(24.width),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "backup_pleasewrite".local(),
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
                        "backup_pleasewrite01".local(),
                        style: TextStyle(
                          fontSize: 16.font,
                          fontWeight: FontWeightUtils.regular,
                          color: ColorUtils.FF8F9397,
                        ),
                      ),
                    ),
                    SortIndexView(
                      memos: _datas,
                      offsetWidth: 48.width,
                      bgColor: ColorUtils.fromHex("#FFEBEEEF"),
                      type: SortIndexType.leftIndex,
                      onTap: (int index) {},
                    ),
                  ],
                ),
              ),
            ),
            NextButton(
              onPressed: _backMemo,
              margin: EdgeInsets.only(top: 10.width),
              title: "button_next".local(),
            ),
          ],
        ),
      ),
    );
  }
}
