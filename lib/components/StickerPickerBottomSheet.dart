import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../utils/DataProvider.dart';

import '../main.dart';

class StickerPickerBottomSheet extends StatefulWidget {
  static String tag = '/StickerPickerBottomSheet';

  @override
  StickerPickerBottomSheetState createState() => StickerPickerBottomSheetState();
}

class StickerPickerBottomSheetState extends State<StickerPickerBottomSheet> {
  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    afterBuildCreated(() => appStore.setLoading(false));
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      width: context.width(),
      decoration: boxDecorationWithRoundedCorners(
        borderRadius: BorderRadius.only(topRight: Radius.circular(12), topLeft: Radius.circular(12)),
      ),
      child: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                48.height,
                Wrap(
                  alignment: WrapAlignment.spaceEvenly,
                  runAlignment: WrapAlignment.spaceEvenly,
                  crossAxisAlignment: WrapCrossAlignment.start,
                  spacing: 16,
                  runSpacing: 16,
                  children: getStickers().map(
                    (e) {
                      return Image.asset(e, width: context.width() / 3 - 32, height: 100).onTap(() {
                        finish(context, e);
                      });
                    },
                  ).toList(),
                ).center(),
              ],
            ),
          ),
          Container(
            decoration: boxDecorationWithRoundedCorners(borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select Sticker',
                  style: boldTextStyle(),
                ),
                Icon(Icons.clear, color: Colors.black).onTap(() {
                  finish(context);
                })
              ],
            ).paddingSymmetric(horizontal: 16, vertical: 16),
          ),
        ],
      ),
    );
  }
}
