import 'package:beewallet/utils/custom_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';

import '../../component/build_point.dart';
import '../../model/mnemonic/mnemonic.dart';
import '../../public.dart';
import 'create/backup_memo.dart';

class ConfigWalletAvatar extends StatefulWidget {
  ConfigWalletAvatar({Key? key}) : super(key: key);

  @override
  State<ConfigWalletAvatar> createState() => _ConfigWalletAvatarState();
}

class _ConfigWalletAvatarState extends State<ConfigWalletAvatar> {
  int _currentIndex = 0;
  int _currentLeng = 0;
  TextEditingController _nameEC = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _nameEC.addListener(() {
      var len = _nameEC.text.length;
      setState(() {
        _currentLeng = len;
      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _nameEC.removeListener(() {});
  }

  void _onTapNext() {
    var text = _nameEC.text;
    if (text.isEmpty) {
      HWToast.showText(text: "createwallet_walletname".local());
      return;
    }
    String memo = Mnemonic.generateMnemonic();
    var avatar = beesIcons[_currentIndex];
    Routers.push(context, BackupMemo(memo: memo, avatarURL: avatar.image));
  }

  @override
  Widget build(BuildContext context) {
    return CustomPageView(
      title: CustomPageView.getTitle(title: "createwallet_title".local()),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  CustomTextField.getInputTextField(
                    context,
                    padding: EdgeInsets.only(
                        top: 24.width, left: 16.width, right: 16.width),
                    controller: _nameEC,
                    titleText: "createwallet_walletname".local(),
                    hintText: "input_name".local(),
                    maxLength: 20,
                    errText: "input_limit".local() + "：$_currentLeng/20",
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(
                        top: 25.width, left: 16.width, right: 16.width),
                    child: Text(
                      "createwallet_tip01".local(),
                      style: TextStyle(
                          fontSize: 16.font, color: ColorUtils.FFB9BFC4),
                    ),
                  ),
                  Container(
                    height: 320.width,
                    alignment: Alignment.topCenter,
                    margin: EdgeInsets.only(top: 35.width, bottom: 35.width),
                    child: Swiper(
                      autoplay: false,
                      loop: false,
                      itemBuilder: (context, index) {
                        var parmas = beesIcons[index];
                        var image = parmas.image;
                        var title = parmas.title;
                        return Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.all(5.width),
                          child: Container(
                            width: 258.width,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: ColorUtils.fromHex("#14000000"),
                                  blurRadius: 12,
                                  spreadRadius: 1,
                                )
                              ],
                            ),
                            child: Column(
                              children: [
                                25.columnWidget,
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: CachedNetworkImage(
                                    imageUrl: image,
                                    width: 208.width,
                                    height: 208.width,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                                Container(
                                  alignment: Alignment.centerLeft,
                                  padding: EdgeInsets.all(25.width),
                                  child: Text(
                                    title,
                                    style: TextStyle(
                                      fontSize: 20.font,
                                      color: ColorUtils.fromHex("#FF333333"),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      itemCount: beesIcons.length,
                      viewportFraction: 0.6,
                      onIndexChanged: (index) {
                        setState(() {
                          _currentIndex = index;
                        });
                      },
                    ),
                  ),
                  BuildPoint(
                    currentIndex: _currentIndex,
                    maxCount: beesIcons.length,
                  ),
                  Container(
                    padding: EdgeInsets.only(
                        top: 24.width,
                        left: 16.width,
                        right: 16.width,
                        bottom: 24.width),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "createwallet_tip".local(),
                      style: TextStyle(
                          fontSize: 14.font, color: ColorUtils.FFB9BFC4),
                    ),
                  ),
                ],
              ),
            ),
          ),
          NextButton(
            margin: EdgeInsets.only(
                left: 16.width, right: 24.width, bottom: 24.width),
            onPressed: () {
              _onTapNext();
            },
            title: "button_next".local(),
          ),
        ],
      ),
    );
  }
}
