import 'package:flutter/widgets.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../public.dart';

class ShareDefaultWidget extends StatelessWidget {
  const ShareDefaultWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String url = SPManager.getLinkInfo(SPManager.setappDownUrl);

    return Container(
      height: 100.width,
      alignment: Alignment.center,
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 20.width),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                alignment: Alignment.center,
                child: Text(
                  "beewallet",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 22.font,
                    fontWeight: FontWeightUtils.bold,
                  ),
                ),
              ),
              10.columnWidget,
              Container(
                color: ColorUtils.fromHex("#1C7685A2"),
                height: 20.width,
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: 5),
                child: Text(
                  "SLOGAN",
                  style: TextStyle(
                    color: ColorUtils.fromHex("#BA0B0D10"),
                    fontSize: 11.font,
                    fontWeight: FontWeightUtils.regular,
                  ),
                ),
              ),
            ],
          ),
          QrImage(
            data: url,
            size: 80.width,
          )
        ],
      ),
    );
  }
}
