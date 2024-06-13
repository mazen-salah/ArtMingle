import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../models/StackedWidgetModel.dart';

class PositionedTextViewWidget extends StatefulWidget {
  final double? left;
  final double? top;
  final Function? onTap;
  final Function(DragUpdateDetails)? onPanUpdate;
  final double? fontSize;
  final String? value;
  final TextAlign? align;

  final StackedWidgetModel? stackedWidgetModel;

  PositionedTextViewWidget({this.left, this.top, this.onTap, this.onPanUpdate, this.fontSize, this.value, this.align, this.stackedWidgetModel});

  @override
  PositionedTextViewWidgetState createState() => PositionedTextViewWidgetState();
}

class PositionedTextViewWidgetState extends State<PositionedTextViewWidget> {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.left,
      top: widget.top,
      child: GestureDetector(
        onTap: widget.onTap as void Function()?,
        onPanUpdate: widget.onPanUpdate,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 400),
          decoration: BoxDecoration(color: widget.stackedWidgetModel!.backgroundColor, borderRadius: radius()),
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text(
            widget.value!,
            textAlign: widget.align,
            style: TextStyle(
              fontSize: widget.fontSize,
              color: widget.stackedWidgetModel?.textColor ?? textPrimaryColorGlobal,
              fontStyle: widget.stackedWidgetModel?.fontStyle ?? FontStyle.normal,
              fontFamily: widget.stackedWidgetModel?.fontFamily ?? GoogleFonts.nunito().fontFamily,
            ),
          ),
        ),
      ),
    );
  }
}
