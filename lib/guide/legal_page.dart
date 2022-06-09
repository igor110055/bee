import '../pages/wallet/create/create_tip.dart';
import '../public.dart';

class LegalPage extends StatefulWidget {
  LegalPage({Key? key}) : super(key: key);

  @override
  State<LegalPage> createState() => _LegalPageState();
}

class _LegalPageState extends State<LegalPage> {
  bool _isNext = true;

  void _onTapTerm() {}

  void _onTapPrivacy() {}

  void _onTapNext() {
    Routers.push(context, CreateTip());
  }

  Widget _buildCell({required String title, VoidCallback? onTap}) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 54.width,
        margin: EdgeInsets.only(bottom: 20.width),
        padding: EdgeInsets.symmetric(horizontal: 16.width),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 12,
              blurStyle: BlurStyle.solid,
              color: ColorUtils.fromHex("#0A000000"),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 20.font,
                color: ColorUtils.FF363B3E,
              ),
            ),
            loadArrowRightIcon(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomPageView(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 24.width),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "legal_title".local(),
                  style: TextStyle(
                    fontSize: 28.font,
                    fontWeight: FontWeightUtils.bold,
                    color: ColorUtils.FF363B3E,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 16.width, bottom: 36.width),
                  child: Text(
                    "legal_tip".local(),
                    style: TextStyle(
                      fontSize: 16.font,
                      color: ColorUtils.FF6B747B,
                    ),
                  ),
                ),
                _buildCell(title: "legal_term".local(), onTap: _onTapTerm),
                _buildCell(
                    title: "legal_privacy".local(), onTap: _onTapPrivacy),
              ],
            ),
          ),
          Expanded(
            child: Container(),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.width),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      child: Text(
                        "legal_readed".local(),
                        style: TextStyle(
                            fontSize: 14.font, color: ColorUtils.FF666666),
                      ),
                    ),
                  ],
                ),
                NextButton(
                  onPressed: _onTapNext,
                  enabled: _isNext,
                  margin: EdgeInsets.only(top: 12.width, bottom: 45.width),
                  title: "button_next".local(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
