import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../utils/Colors.dart';

class HomeItemWidget extends StatelessWidget {
  static String tag = '/HomeItemWidget';
  final Function? onTap;
  final Widget? widget;
  final double? width;
  final double? height;

  HomeItemWidget({this.onTap, this.widget, this.height, this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: radius(8),
        gradient: LinearGradient(colors: [
          itemGradient1,
          itemGradient2,
        ], end: Alignment.topCenter, begin: Alignment.bottomCenter),
      ),
      child: Material(
        color: Colors.white24,
        child: InkWell(
           splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.transparent,
          onTap: onTap as void Function()?,
          child: widget.paddingAll(16),
          borderRadius: radius(30),
        ),
      ),
    );
  }
}
