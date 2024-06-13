import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../utils/Colors.dart';

class TextEditorDialog extends StatefulWidget {
  static String tag = '/AddTextDialog';
  final String? text;
  TextEditorDialog({this.text});

  @override
  State<TextEditorDialog> createState() => _TextEditorDialogState();
}

class _TextEditorDialogState extends State<TextEditorDialog> {
  final TextEditingController name = TextEditingController();
  @override
  void initState() {
    super.initState();
    // TODO: implement initState
   if(widget.text!= null){
     name.text=widget.text!;
   }
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      width: context.width(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppTextField(
            controller: name,
            textFieldType: TextFieldType.NAME,
            decoration: InputDecoration(
              labelText: 'Text',
              labelStyle: primaryTextStyle(),
              enabledBorder: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(),
            ),
            scrollPadding: EdgeInsets.all(20.0),
            keyboardType: TextInputType.multiline,
            maxLines: 99999,
            autoFocus: true,
          ),
          16.height,
          AppButton(
            text: 'Done',
            width: context.width(),
            color: colorPrimary,
            textStyle: boldTextStyle(color: Colors.white),
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 30),
            onTap: () {
              if (name.text.trim().isNotEmpty) {
                finish(context, name.text);
              } else {
                toast('Write something');
              }
            },
          ),
        ],
      ),
    );
  }
}
