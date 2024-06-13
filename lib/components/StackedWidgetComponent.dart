import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:zoom_widget/zoom_widget.dart';
import '../../models/StackedWidgetModel.dart';
import '../../utils/Constants.dart';

import '../main.dart';
import 'PositionedNeonTextWidget.dart';
import 'PositionedTextViewWidget.dart';
import 'StackedItemConfigWidget.dart';

class StackedWidgetComponent extends StatefulWidget {
  static String tag = '/StackedWidgetComponent';
  final List<StackedWidgetModel> multiWidget;

  StackedWidgetComponent(this.multiWidget);

  @override
  StackedWidgetComponentState createState() => StackedWidgetComponentState();
}

class StackedWidgetComponentState extends State<StackedWidgetComponent> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      children: widget.multiWidget.map((item) {
        if (item.widgetType == WidgetTypeText) {
          return PositionedTextViewWidget(
            value: item.value.validate(),
            left: item.offset!.dx,
            top: item.offset!.dy,
            align: TextAlign.center,
            fontSize: item.size,
            stackedWidgetModel: item,
            onTap: () async {
              var data = await showModalBottomSheet<dynamic>(
                context: context,
                isScrollControlled: true,
                builder: (_) => StackedItemConfigWidget(stackedWidgetModel: item, voidCallback: () => setState(() {})),
                backgroundColor: Colors.transparent,
              );
              if (data != null) {
                widget.multiWidget.remove(data);
              }
              // appStore.isText = true;
              setState(() {});
            },
            onPanUpdate: (details) {
              item.offset = Offset(item.offset!.dx + details.delta.dx, item.offset!.dy + details.delta.dy);
              setState(() {});
            },
          );
        } else if (item.widgetType == WidgetTypeEmoji) {
          return PositionedTextViewWidget(
            value: item.value.validate(),
            left: item.offset!.dx,
            top: item.offset!.dy,
            align: TextAlign.center,
            fontSize: item.size,
            stackedWidgetModel: item,
            onTap: () async {
              var data = await showModalBottomSheet(
                context: context,
                builder: (_) => StackedItemConfigWidget(stackedWidgetModel: item, voidCallback: () => setState(() {})),
                backgroundColor: Colors.transparent,
              );
              if (data != null) {
                widget.multiWidget.remove(data);
              }
              setState(() {});
            },
            onPanUpdate: (details) {
              item.offset = Offset(item.offset!.dx + details.delta.dx, item.offset!.dy + details.delta.dy);

              setState(() {});
            },
          );
        } else if (item.widgetType == WidgetTypeNeon) {
          return PositionedNeonTextWidget(
            value: item.value.validate(),
            left: item.offset!.dx,
            top: item.offset!.dy,
            align: TextAlign.center,
            fontSize: item.size,
            stackedWidgetModel: item,
            onTap: () async {
              var data = await showModalBottomSheet<dynamic>(
                context: context,
                isScrollControlled: true,
                builder: (_) => StackedItemConfigWidget(stackedWidgetModel: item, voidCallback: () => setState(() {})),
                backgroundColor: Colors.transparent,
              );
              // ignore: unnecessary_null_comparison
              if (data != null) {
                widget.multiWidget.remove(data);
              }
              setState(() {});
            },
            onPanUpdate: (details) {
              item.offset = Offset(item.offset!.dx + details.delta.dx, item.offset!.dy + details.delta.dy);
              setState(() {});
            },
          );
        } else if (item.widgetType == WidgetTypeSticker) {
          return Positioned(
            left: item.offset!.dx,
            top: item.offset!.dy,
            child: GestureDetector(
              onTap: () async {
                var data = await showModalBottomSheet(
                  context: context,
                  builder: (_) => StackedItemConfigWidget(stackedWidgetModel: item, voidCallback: () => setState(() {})),
                  backgroundColor: Colors.transparent,
                );
                if (data != null) {
                  widget.multiWidget.remove(data);
                }
                setState(() {});
              },
              onPanUpdate: (details) {
                item.offset = Offset(item.offset!.dx + details.delta.dx, item.offset!.dy + details.delta.dy);
                setState(() {});
              },
              child: Image.asset(item.value!, height: item.size),
            ),
          );
        } else if (item.widgetType == WidgetTypeImage) {
          return Positioned(
            left: item.offset!.dx,
            top: item.offset!.dy,
            child: GestureDetector(
              onTap: () async {
                var data = await showModalBottomSheet(
                  context: context,
                  builder: (_) => StackedItemConfigWidget(stackedWidgetModel: item, voidCallback: () => setState(() {})),
                  backgroundColor: Colors.transparent,
                );
                if (data != null) {
                  widget.multiWidget.remove(data);
                }
                setState(() {});
              },
              onPanUpdate: (details) {
                item.offset = Offset(item.offset!.dx + details.delta.dx, item.offset!.dy + details.delta.dy);
                setState(() {});
              },
              child: Image.file(item.file!, width: item.size),
            ),
          );
        } else if (item.widgetType == WidgetTypeContainer) {
          return Positioned(
            left: item.offset!.dx,
            top: item.offset!.dy,
            child: GestureDetector(
              onTap: () async {
                var data = await showModalBottomSheet(
                  context: context,
                  builder: (_) => StackedItemConfigWidget(stackedWidgetModel: item, voidCallback: () => setState(() {})),
                  backgroundColor: Colors.transparent,
                );
                if (data != null) {
                  widget.multiWidget.remove(data);
                }
                setState(() {});
              },
              onPanUpdate: (details) {
                item.offset = Offset(item.offset!.dx + details.delta.dx, item.offset!.dy + details.delta.dy);
                setState(() {});
              },
              child: Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                    child: Container(
                      alignment: Alignment.center,
                      // Choose Colors.black.withOpacity(0.3) here if you want a shadow effect in addition to blurring.
                      color: Colors.transparent,
                      // This part is new, creating the cutout.
                      // child: CustomPaint(painter: Hole()),
                    ),
                  ),
                  Container(width: item.size, height: item.size, decoration: BoxDecoration(color: Colors.transparent, shape: item.shape!)),
                ],
              ),
              // Container(width: item.size,height: item.size,decoration:BoxDecoration(color: Colors.white.withOpacity(0.5),shape:item.shape!)),
            ),
          );
        } else if (item.widgetType == WidgetTypeTextTemplate) {
          return Positioned(
            left: item.offset!.dx,
            top: item.offset!.dy,
            child: GestureDetector(
              onTap: () async {
                var data = await showModalBottomSheet(
                  context: context,
                  builder: (_) => StackedItemConfigWidget(stackedWidgetModel: item, voidCallback: () => setState(() {})),
                  backgroundColor: Colors.transparent,
                );

                if (data != null) {
                  widget.multiWidget.remove(data);
                }
                setState(() {});
              },
              onPanUpdate: (details) {
                item.offset = Offset(item.offset!.dx + details.delta.dx, item.offset!.dy + details.delta.dy);
                setState(() {});
              },
              child: Container(
                  width: item.size! + 60,
                  height: item.size,
                  padding: EdgeInsets.all(item.size! * 0.2),
                  decoration: BoxDecoration(image: DecorationImage(image: AssetImage(item.imageName!), fit: BoxFit.fill)),
                  child: Text(item.value!, style: TextStyle(color: item.textColor, fontStyle: item.fontStyle, fontSize: item.fontSize), softWrap: true)),
            ),
          );
        }
        return Container();
      }).toList(),
    );
  }
}

class Hole extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double radius = 100;
    canvas.drawCircle(Offset(100, 130), radius, Paint()..blendMode = BlendMode.xor
        // The mask filter gives some fuziness to the cutout.
        // ..maskFilter = MaskFilter.blur(BlurStyle.normal, blurRadius),
        );
  }

  @override
  bool shouldRepaint(Hole oldDelegate) => false;
}
