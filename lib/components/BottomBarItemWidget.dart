import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class BottomBarItemWidget extends StatelessWidget {
  final Color? color;
  final Function? onTap;
  final String? title;
  final IconData? icons;
  final bool? isPremium;

  BottomBarItemWidget({this.color, this.onTap, this.title, this.icons, this.isPremium = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width() / 5.9,
      height: 60,
      decoration: BoxDecoration(color: color),
      alignment: Alignment.center,
      child: Material(
        color: Colors.white24,
        child: InkWell(
          splashFactory:NoSplash.splashFactory,
          highlightColor: Colors.transparent,
          onTap: () {
            onTap!.call();
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(icons, color: Colors.black, size: 22),
                  8.height,
                  Text(title.validate(), style: secondaryTextStyle(color: Colors.black, size: 13)).fit(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
