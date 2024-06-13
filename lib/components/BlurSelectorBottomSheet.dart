import 'package:flutter/material.dart';

// ignore: must_be_immutable
class BlurSelectorBottomSheet extends StatefulWidget {
  static String tag = '/BlurSelectorBottomSheet';
  final Function(double)? onColorSelected;
  final Function(double)? onColorSelectedEnd;

  double? sliderValue;

  BlurSelectorBottomSheet({this.sliderValue, this.onColorSelected,this.onColorSelectedEnd});

  @override
  BlurSelectorBottomSheetState createState() => BlurSelectorBottomSheetState();
}

class BlurSelectorBottomSheetState extends State<BlurSelectorBottomSheet> {
  double sliderValue = 2.0;

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Slider(
        value: widget.sliderValue!,
        min: 0.0,
        max: 10.0,
        divisions: 100,
        label: '${widget.sliderValue!.round()}',
        onChanged: (double value) {
          widget.sliderValue = value;
          widget.onColorSelected!.call(value);
          setState(() {});
        },
        onChangeEnd: (value) {
          widget.onColorSelectedEnd!.call(value);
        },
      ),
    );
  }
}
