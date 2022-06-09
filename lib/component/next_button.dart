import '../../public.dart';

typedef NextButtonCallback = void Function();

class NextButton extends StatelessWidget {
  const NextButton(
      {Key? key,
      required this.onPressed,
      this.bgc,
      required this.title,
      this.enabled = true,
      this.height = 62.0,
      this.borderRadius = 12,
      this.margin,
      this.padding,
      this.border,
      this.textStyle,
      this.enableColor = const Color(0xFFFFE48D),
      this.bgImg,
      this.width,
      this.child})
      : super(key: key);

  final NextButtonCallback onPressed;
  final Color? bgc;
  final String title;
  final bool enabled;

  ///原始值
  final double height;

  ///原始值
  final double? width;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BoxBorder? border;
  final TextStyle? textStyle;
  final Color? enableColor;
  final Widget? child;

  ///Constant.ASSETS_IMG + "icons/buttongradient.png",
  final String? bgImg;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _buttonOnPressed(context),
      child: Container(
        alignment: Alignment.center,
        height: height.width,
        margin: margin,
        padding: padding,
        width: width?.width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius ?? 0),
          border: border,
          color: enabled == true ? (bgc ?? ColorUtils.FFFFC200) : enableColor,
          image: bgImg == null
              ? null
              : DecorationImage(
                  fit: BoxFit.contain,
                  image: AssetImage(bgImg!),
                ),
        ),
        child: child ??
            Text(
              title,
              textAlign: TextAlign.center,
              style: textStyle ??
                  TextStyle(
                    fontSize: 20.font,
                    color: Colors.white,
                  ),
            ),
      ),
    );
  }

  void _buttonOnPressed(BuildContext context) {
    FocusScope.of(context).requestFocus(FocusNode());
    if (enabled) {
      onPressed();
    }
  }
}
