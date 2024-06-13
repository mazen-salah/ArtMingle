import 'package:flutter/material.dart';

class ColorFilterModel {
  String? name;
  List<Color>? color;
  List<double>? matrix;

  BlendMode? blendMode;
  Color? filterColor;

  ColorFilterModel({this.name, this.color, this.blendMode, this.filterColor, this.matrix});
}
