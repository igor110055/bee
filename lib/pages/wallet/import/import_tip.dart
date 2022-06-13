import '../../../public.dart';
import 'import_wallets.dart';

class ImportTip extends StatefulWidget {
  ImportTip({Key? key}) : super(key: key);

  @override
  State<ImportTip> createState() => _ImportTipState();
}

class _ImportTipState extends State<ImportTip> {
  void _onTapPrv() {
    Routers.push(context, ImportsWallet(leadType: KLeadType.Prvkey));
  }

  void _onTapMemo() {
    Routers.push(context, ImportsWallet(leadType: KLeadType.Memo));
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
                        "importwallet_tip".local(),
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
                        "importwallet_tip01".local(),
                        style: TextStyle(
                          fontSize: 16.font,
                          fontWeight: FontWeightUtils.regular,
                          color: ColorUtils.FF8F9397,
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.only(top: 12.width),
                      child: Text(
                        "importwallet_tip02".local(),
                        style: TextStyle(
                          fontSize: 14.font,
                          fontWeight: FontWeightUtils.regular,
                          color: ColorUtils.fromHex("#FFFFC200"),
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      child: LoadAssetsImage(
                        "guide/guide_04.png",
                        width: 400.width,
                        height: 410.width,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            NextButton(
              onPressed: _onTapPrv,
              title: "importwallet_prv".local(),
            ),
            32.columnWidget,
            NextButton(
              onPressed: _onTapMemo,
              title: "importwallet_memo".local(),
            ),
          ],
        ),
      ),
    );
  }
}
