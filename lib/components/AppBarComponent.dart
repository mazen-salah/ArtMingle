import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../utils/Colors.dart';

AppBar appBarComponent({required BuildContext context, String? title, List<Widget>? list}) {
  return AppBar(
    title: Text(title!, style: boldTextStyle(color: Colors.white, size: 20, letterSpacing: 0.3, wordSpacing: 0.5)),
    backgroundColor: Colors.transparent,
    foregroundColor: Colors.white,
    iconTheme: IconThemeData(color: Colors.white),
    flexibleSpace: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            itemGradient1,
            itemGradient2,
          ],
          end: Alignment.centerLeft,
          begin: Alignment.centerRight,
        ),
      ),
    ),
    actions: list,
  );
}
