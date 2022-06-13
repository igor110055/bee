import 'package:beewallet/component/custom_underline.dart';
import 'package:beewallet/pages/wallet/config_wallet_avatar.dart';
import '../../../public.dart';
import '../../scan/scan.dart';

class ImportsWallet extends StatefulWidget {
  ImportsWallet({Key? key, required this.leadType}) : super(key: key);
  final KLeadType leadType;

  @override
  State<ImportsWallet> createState() => _ImportsWalletState();
}

class _ImportsWalletState extends State<ImportsWallet> {
  TextEditingController _contentEC = TextEditingController();
  bool _isOk = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if (inProduction == false) {}
  }

  void _createWallet() {
    Routers.push(context, ConfigWalletAvatar());
  }

  @override
  Widget build(BuildContext context) {
    return CustomPageView(
      actions: [
        CustomPageView.getScan(() async {
          Map? params = await Routers.push(context, ScanCodePage());
          String result = params?["data"] ?? "";
          _contentEC.text = result;
        }),
      ],
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
                    CustomTextField.getInputTextField(context,
                        padding: EdgeInsets.only(top: 16.width),
                        controller: _contentEC,
                        maxLines: 5,
                        hintText: "input_name".local()),
                  ],
                ),
              ),
            ),
            NextButton(
                enabled: _isOk,
                onPressed: _createWallet,
                title: "button_restore".local())
          ],
        ),
      ),
    );
  }
}
