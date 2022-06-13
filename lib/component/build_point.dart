import '../public.dart';

class BuildPoint extends StatelessWidget {
  const BuildPoint(
      {Key? key, required this.maxCount, required this.currentIndex})
      : super(key: key);

  final int maxCount;
  final int currentIndex;

  Widget _buildPoint() {
    return Container(
      width: 60.width,
      height: 10.width,
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(maxCount, (int index) {
          return _pointWidget(index);
        }).toList(),
      ),
    );
  }

  Widget _pointWidget(int index) {
    var imageName = "";
    if (index == currentIndex) {
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
    return _buildPoint();
  }
}
