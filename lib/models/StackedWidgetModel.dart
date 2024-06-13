import 'package:flutter/material.dart';
import 'dart:io';

class StackedWidgetModel {
  String? widgetType;
  String? imageName;
  String? value;
  Offset? offset;
  double? size;
  FontStyle? fontStyle;
  File? file;
  BoxShape? shape;

  // Text Widget Properties
  Color? textColor;
  Color? backgroundColor;
  String? fontFamily;
  double? fontSize;

  StackedWidgetModel({
    this.widgetType,
    this.value,
    this.offset,
    this.size,
    this.textColor,
    this.backgroundColor,
    this.fontStyle,
    this.fontFamily,
    this.file,
    this.shape,
    this.imageName,
    this.fontSize,
  });
}
