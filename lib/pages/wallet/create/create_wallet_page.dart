import 'package:beewallet/state/create/create_wallet_state.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';

import '../../../component/build_point.dart';
import '../../../public.dart';

class CreateWalletPage extends StatefulWidget {
  CreateWalletPage({Key? key}) : super(key: key);

  @override
  State<CreateWalletPage> createState() => _CreateWalletPageState();
}

class _CreateWalletPageState extends State<CreateWalletPage> {
  final CreateWalletProvider _kprovier = CreateWalletProvider.init(
      leadType: KLeadType.Memo, chainType: KChainType.HD);

  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => _kprovier,
      child: CustomPageView(
        title: CustomPageView.getTitle(title: "createwallet_title".local()),
        child: Container(
          padding: EdgeInsets.all(16.width),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      CustomTextField.getInputTextField(
                        context,
                        padding: EdgeInsets.only(top: 24.width),
                        controller: _kprovier.walletNameEC,
                        titleText: "createwallet_walletname".local(),
                        hintText: "input_name".local(),
                        maxLength: 20,
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.only(top: 35.width),
                        child: Text(
                          "createwallet_tip01".local(),
                          style: TextStyle(
                              fontSize: 16.font, color: ColorUtils.FFB9BFC4),
                        ),
                      ),
                      Container(
                        height: 330.height,
                        alignment: Alignment.topCenter,
                        // margin:
                        //     EdgeInsets.only(top: 35.width, bottom: 35.width),
                        child: Swiper(
                          autoplay: false,
                          loop: false,
                          itemBuilder: (context, index) {
                            var parmas = beesIcons[index];
                            var image = parmas["image"];
                            var title = parmas["title"];
                            return Container(
                              alignment: Alignment.center,
                              // margin: EdgeInsets.only(right: 25.width),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: ColorUtils.fromHex("#14000000"),
                                    blurRadius: 12,
                                    spreadRadius: 1,
                                  )
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: EdgeInsets.all(15.width),
                                  width: 208.width,
                                  height: 208.width,
                                  child: Column(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: CachedNetworkImage(
                                          imageUrl: image,
                                          width: 208.width,
                                          height: 208.width,
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                          itemCount: beesIcons.length,
                          viewportFraction: 0.8,
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
                        padding: EdgeInsets.only(top: 24.width),
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
                onPressed: () {
                  _kprovier.createWallet(context);
                },
                title: "button_next".local(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
