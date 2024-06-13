import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../utils/Colors.dart';

class ColorSelectorBottomSheet extends StatelessWidget {
  static String tag = '/ColorSelectorBottomSheet';
  final List<Color> list;
  final Function(Color)? onColorSelected;
  final Color? selectedColor;

  ColorSelectorBottomSheet({required this.list, this.onColorSelected, this.selectedColor});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Wrap(
          direction: Axis.horizontal,
          spacing: 16,
          runSpacing: 16,
          crossAxisAlignment: WrapCrossAlignment.start,
          children: list.map((e) {
            return Stack(
              alignment: Alignment.center,
              children: [
                ColorItemWidget(
                  color: e,
                  onTap: () {
                    return onColorSelected!.call(e);
                  },
                ),
                if (selectedColor != null) Icon(Icons.done, color: e.isDark() ? itemGradient2 : itemGradient1).visible(selectedColor == e),
              ],
            );
          }).toList(),
        ).paddingLeft(16),
      ),
    );
  }
}

class ColorItemWidget extends StatelessWidget {
  final Color? color;
  final Function? onTap;

  ColorItemWidget({this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      width: 30,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: Border.all()),
    ).onTap(() {
      onTap!.call();
    }, borderRadius: BorderRadius.circular(60));
  }
}
