import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../utils/Constants.dart';
import 'package:photo_view/photo_view.dart';

import '../main.dart';

class CollegeMakerLayoutWidget extends StatefulWidget {
  final List<int>? columnCountList;
  final double? borderWidth;
  final double? borderRadius;
  final Color? borderColor;
  final double? spacing;

  CollegeMakerLayoutWidget({this.columnCountList, this.borderWidth = 0.0, this.borderColor, this.borderRadius = 0.0, this.spacing = 0.0});

  @override
  _CollegeMakerLayoutWidgetState createState() => _CollegeMakerLayoutWidgetState();
}

class _CollegeMakerLayoutWidgetState extends State<CollegeMakerLayoutWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    int _imageItemIndex = 0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius! / 3),
      child: Container(
        width: context.width(),
        height: context.height(),
        color: widget.borderColor,
        padding: EdgeInsets.all(widget.borderWidth == 0 ? 0 : itemSpacing.toDouble()),
        child: LayoutBuilder(
          builder: (ctx, constraint) {
            return widget.columnCountList![0] != 0
                ? AnimatedSwitcher(
                    duration: Duration(milliseconds: 500),
                    reverseDuration: Duration(milliseconds: 500),
                    child: Row(
                      children: List.generate(widget.columnCountList!.length, (index) {
                        return Column(
                          children: List.generate(widget.columnCountList![index].toInt(), (i) {
                            return Container(
                              padding: EdgeInsets.all(widget.spacing!),
                              decoration: BoxDecoration(
                                border: widget.borderWidth == 0 ? Border() : Border.all(color: widget.borderColor!, width: widget.borderWidth!),
                              ),
                              width: ctx.width() / 2,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(widget.borderRadius!),
                                child: PhotoView(
                                  imageProvider: Image.file(appStore.collegeMakerImageList[_imageItemIndex++]).image,
                                  basePosition: Alignment.center,
                                  enableRotation: true,
                                  maxScale: PhotoViewComputedScale.covered * 2.0,
                                  minScale: PhotoViewComputedScale.contained * 1.0,
                                  initialScale: PhotoViewComputedScale.covered,
                                  filterQuality: FilterQuality.none,
                                ),
                              ),
                            ).expand();
                          }),
                        ).expand();
                      }),
                    ),
                  )
                : AnimatedSwitcher(
                    duration: Duration(milliseconds: 500),
                    reverseDuration: Duration(milliseconds: 500),
                    child: Column(
                      children: List.generate(widget.columnCountList!.length - 1, (index) {
                        return Row(
                          children: List.generate(widget.columnCountList![index + 1].toInt(), (i) {
                            return Container(
                              padding: EdgeInsets.all(widget.spacing!),
                              decoration: BoxDecoration(
                                border: widget.borderWidth == 0 ? Border() : Border.all(color: widget.borderColor!, width: widget.borderWidth!),
                              ),
                              width: ctx.width(),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(widget.borderRadius!),
                                child: PhotoView(
                                  imageProvider: Image.file(appStore.collegeMakerImageList[_imageItemIndex++]).image,
                                  basePosition: Alignment.center,
                                  enableRotation: true,
                                  maxScale: PhotoViewComputedScale.covered * 2.0,
                                  minScale: PhotoViewComputedScale.contained * 1.0,
                                  initialScale: PhotoViewComputedScale.covered,
                                  filterQuality: FilterQuality.none,
                                ),
                              ),
                            ).expand();
                          }),
                        ).expand();
                      }),
                    ),
                  );
          },
        ),
      ),
    );
  }
}
