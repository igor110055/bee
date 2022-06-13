import 'package:beewallet/component/build_point.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';
import '../pages/wallet/import/import_tip.dart';
import '../public.dart';
import 'legal_page.dart';

class GuidePage extends StatefulWidget {
  GuidePage({Key? key}) : super(key: key);

  @override
  _GuidePageState createState() => _GuidePageState();
}

class _GuidePageState extends State<GuidePage> {
  int _currentIndex = 0;
  // "guide/guide_01.png",
  // "guide/guide_02.png",
  // "guide/guide_03.png",
  // "guide/guide_04.png",
  final List<Map> _guideImages = [
    {
      "image": "guide/guide_01.png",
      "title": "guide_01_title".local(),
      "content": "guide_01_content".local()
    },
    {
      "image": "guide/guide_02.png",
      "title": "guide_02_title".local(),
      "content": "guide_02_content".local()
    },
    {
      "image": "guide/guide_03.png",
      "title": "guide_03_title".local(),
      "content": "guide_03_content".local(),
    },
    {
      "image": "guide/guide_04.png",
      "title": "guide_04_title".local(),
      "content": "guide_04_content".local()
    },
  ];

  @override
  void initState() {
    super.initState();
  }

  void onDonePress() {
    updateSkin();
  }

  void updateSkin() async {}

  void _createNewWallet() {
    Routers.push(context, LegalPage());
  }

  void _importNewWallet() {
    Routers.push(context, ImportTip());
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: CustomPageView(
        hiddenAppBar: true,
        safeAreaTop: false,
        child: Padding(
          padding: EdgeInsets.only(left: 16.width, right: 16.width),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                height: 600.height,
                alignment: Alignment.topCenter,
                child: Swiper(
                  autoplay: false,
                  loop: false,
                  itemCount: _guideImages.length,
                  itemBuilder: (_, index) {
                    var parmas = _guideImages[index];
                    var image = parmas["image"];
                    var title = parmas["title"];
                    var content = parmas["content"];

                    return Column(
                      children: [
                        LoadAssetsImage(
                          image,
                          width: 400.width,
                          height: 410.width,
                        ),
                        DelayedDisplay(
                          delay: Duration(milliseconds: 200),
                          child: Text(
                            title,
                            style: TextStyle(
                                fontWeight: FontWeightUtils.bold,
                                fontSize: 28.font,
                                color: ColorUtils.FFFFC200),
                          ),
                        ),
                        DelayedDisplay(
                          delay: Duration(milliseconds: 200),
                          child: Container(
                            padding: EdgeInsets.only(top: 10.width),
                            child: Text(
                              content,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16.font,
                                color: ColorUtils.FF363B3E,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                  onIndexChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                ),
              ),
              Expanded(child: Container()),
              BuildPoint(
                currentIndex: _currentIndex,
                maxCount: _guideImages.length,
              ),
              NextButton(
                margin: EdgeInsets.only(top: 30.width),
                onPressed: _createNewWallet,
                title: "home_createnew".local(),
              ),
              NextButton(
                onPressed: _importNewWallet,
                bgc: Colors.transparent,
                margin: EdgeInsets.only(bottom: 40.width),
                textStyle: TextStyle(
                  fontSize: 20.font,
                  color: ColorUtils.FFFFC200,
                ),
                title: "home_importnew".local(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
