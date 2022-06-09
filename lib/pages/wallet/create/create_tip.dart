import 'package:delayed_display/delayed_display.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';
import '../../../public.dart';

class CreateTip extends StatefulWidget {
  CreateTip({Key? key}) : super(key: key);

  @override
  State<CreateTip> createState() => _CreateTipState();
}

class _CreateTipState extends State<CreateTip> {
  int _currentIndex = 0;
  final List<Map> _guideImages = [
    {
      "image": "guide/create_guide_01.png",
      "title": "createtip_01_title".local(),
      "content": "createtip_01_content".local()
    },
    {
      "image": "guide/create_guide_02.png",
      "title": "createtip_02_title".local(),
      "content": "createtip_02_content".local()
    },
    {
      "image": "guide/create_guide_03.png",
      "title": "createtip_03_title".local(),
      "content": "createtip_03_content".local(),
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

  void _createNewWallet() {}

  void _importNewWallet() {}

  Widget _buildPoint() {
    return Container(
      width: 60.width,
      height: 10.width,
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(_guideImages.length, (int index) {
          return _pointWidget(index);
        }).toList(),
      ),
    );
  }

  Widget _pointWidget(int index) {
    var imageName = "";
    if (index == _currentIndex) {
      imageName = "guide/guide_choose.png";
    } else {
      imageName = "guide/guide_normal.png";
    }

    return Container(
      width: 9.width,
      height: 9.width,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(ASSETS_IMG + imageName),
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomPageView(
      safeAreaTop: false,
      child: Padding(
        padding: EdgeInsets.only(left: 16.width, right: 16.width),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              height: 550.height,
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
                              color: ColorUtils.FF363B3E),
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
                              color: ColorUtils.FF8F9397,
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
            _buildPoint(),
            NextButton(
              margin: EdgeInsets.only(top: 30.width, bottom: 45.width),
              onPressed: _createNewWallet,
              title: "button_backup".local(),
            ),
          ],
        ),
      ),
    );
  }
}
