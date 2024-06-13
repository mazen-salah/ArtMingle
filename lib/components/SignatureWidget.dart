import 'package:flutter/material.dart';
import '../../utils/SignatureLibWidget.dart';

// ignore: must_be_immutable
class SignatureWidget extends StatefulWidget {
  final SignatureController? signatureController;
  final double? height;
  final double? width;

  List<Offset?>? points;

  SignatureWidget({this.signatureController, this.points, this.height, this.width});

  @override
  _SignatureWidgetState createState() => _SignatureWidgetState();
}

class _SignatureWidgetState extends State<SignatureWidget> {
  @override
  void initState() {
    super.initState();
    widget.signatureController!.addListener(() => print('Value changed'));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: GestureDetector(
        onPanUpdate: (DragUpdateDetails details) {
          setState(() {
            RenderBox object = context.findRenderObject() as RenderBox;
            var _localPosition = object.globalToLocal(details.globalPosition);
            widget.points = List.from(widget.points!)..add(_localPosition);
          });
        },
        onPanEnd: (DragEndDetails details) {
          widget.points!.add(null);
        },
        child: ListView(
          children: <Widget>[
            Signature(
              controller: widget.signatureController,
              height: widget.height,
              width: widget.width,
              backgroundColor: Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }
}
