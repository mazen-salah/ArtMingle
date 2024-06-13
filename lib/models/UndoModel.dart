import 'BorderModel.dart';
import 'ColorFilterModel.dart';
import 'StackedWidgetModel.dart';

class UndoModel{
  String? type;
  double? number;
  String? data;
  StackedWidgetModel? widget;
  ColorFilterModel? filter;
  BorderModel? border;
  UndoModel({this.widget,this.data,this.type,this.filter,this.number,this.border});
}