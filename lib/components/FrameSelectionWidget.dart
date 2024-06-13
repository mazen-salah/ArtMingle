import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../utils/DataProvider.dart';

class FrameSelectionWidget extends StatefulWidget {
  static String tag = '/FrameSelectionWidget';
  final Function(String frame)? onSelect;

  FrameSelectionWidget({this.onSelect});

  @override
  FrameSelectionWidgetState createState() => FrameSelectionWidgetState();
}

class FrameSelectionWidgetState extends State<FrameSelectionWidget> {

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      scrollDirection: Axis.horizontal,
      children: getFrameList().map((e) {
        return Container(
          height: 60,
          width: 100,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: radius(),
            image: e.frame!.isNotEmpty ? DecorationImage(image: ExactAssetImage(e.frame!), fit: BoxFit.cover) : null,
          ),
          margin: EdgeInsets.all(2),
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(e.name!, style: primaryTextStyle()).fit().visible(e.name!.isNotEmpty),
        ).onTap(() {
          widget.onSelect?.call(e.frame.toString());
        });
      }).toList(),
    );
  }
}
