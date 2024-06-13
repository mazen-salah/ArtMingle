import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:photo_editor_pro/main.dart';
import '../../models/FontData.dart';
import '../../models/StackedWidgetModel.dart';
import '../../utils/Colors.dart';
import '../../utils/Constants.dart';
import '../../utils/DataProvider.dart';

import 'ColorSelectorBottomSheet.dart';

// ignore: must_be_immutable
class StackedItemConfigWidget extends StatefulWidget {
  StackedWidgetModel? stackedWidgetModel;
  final VoidCallback? voidCallback;

  StackedItemConfigWidget({this.stackedWidgetModel, this.voidCallback});

  @override
  StackedItemConfigWidgetState createState() => StackedItemConfigWidgetState();
}

class StackedItemConfigWidgetState extends State<StackedItemConfigWidget> {
  List<FontData> fontList = getFontFamilies();
  FontData? selectedFontFamily;
  TextEditingController _textEditingController = TextEditingController(text: '');

  @override
  void initState() {
    super.initState();
    if (widget.stackedWidgetModel!.widgetType == WidgetTypeImage) {
      _textEditingController.text = widget.stackedWidgetModel!.file!.path.validate();
    } else {
      _textEditingController.text = widget.stackedWidgetModel!.value.validate();
    }
    selectedFontFamily = fontList.first;

    log(selectedFontFamily);
  }

  @override
  Widget build(BuildContext context) {
    bool isTextTypeWidget = widget.stackedWidgetModel!.widgetType.validate() == WidgetTypeNeon || widget.stackedWidgetModel!.widgetType.validate() == WidgetTypeText;
    bool isTextWidget = widget.stackedWidgetModel!.widgetType.validate() == WidgetTypeText;
    // bool isNeonWidget = widget.stackedWidgetModel!.widgetType.validate() == WidgetTypeNeon;
    // bool isEmojiWidget = widget.stackedWidgetModel!.widgetType.validate() == WidgetTypeEmoji;
    bool isStickerWidget = widget.stackedWidgetModel!.widgetType.validate() == WidgetTypeSticker ||
        widget.stackedWidgetModel!.widgetType.validate() == WidgetTypeImage ||
        widget.stackedWidgetModel!.widgetType.validate() == WidgetTypeContainer;

    return Container(
      margin: EdgeInsets.only(top: 32),
      height: context.height(),
      decoration: BoxDecoration(color: Colors.white, borderRadius: radiusOnly(topLeft: 16, topRight: 16)),
      child: widget.stackedWidgetModel!.widgetType == WidgetTypeTextTemplate
          ? Stack(
              alignment: Alignment.topLeft,
              children: [
                SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      32.height,
                      AppTextField(
                        textFieldType: TextFieldType.NAME,
                        controller: _textEditingController,
                        onChanged: (s) async {
                          await 1.seconds.delay;
                          widget.stackedWidgetModel!.value = s;
                          widget.voidCallback!.call();
                        },
                      ).paddingBottom(8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          16.height,
                          Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            children: [
                              Text('Normal', style: boldTextStyle()).onTap(() {
                                widget.stackedWidgetModel!.fontStyle = FontStyle.normal;
                                widget.voidCallback!.call();
                                setState(() {});
                              }),
                              Text('Italic', style: boldTextStyle(fontStyle: FontStyle.italic)).onTap(() {
                                widget.stackedWidgetModel!.fontStyle = FontStyle.italic;
                                widget.voidCallback!.call();
                                setState(() {});
                              }),
                            ],
                          ),
                        ],
                      ),
                      8.height,
                      if (selectedFontFamily != null && isTextWidget)
                        Row(
                          children: [
                            Text('Font family :', style: primaryTextStyle()),
                            8.width,
                            DropdownButton(
                              isExpanded: true,
                              value: selectedFontFamily,
                              items: fontList.map((e) {
                                return DropdownMenuItem(child: Text(e.fontName!, style: primaryTextStyle(fontFamily: GoogleFonts.getFont(e.fontName!).fontFamily)), value: e);
                              }).toList(),
                              // underline: SizedBox(),
                              onChanged: (FontData? s) {
                                selectedFontFamily = s;

                                widget.stackedWidgetModel!.fontFamily = s!.fontFamily;
                                widget.voidCallback!.call();

                                setState(() {});
                              },
                            ).expand(),
                          ],
                        ),
                      8.height,
                      Text('Size :', style: primaryTextStyle()),
                      Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          Slider(
                            value: widget.stackedWidgetModel!.fontSize.validate(value: 16),
                            min: 10.0,
                            max: 55.0,
                            onChangeEnd: (v) {
                              widget.stackedWidgetModel!.fontSize = v;
                              widget.voidCallback!.call();

                              setState(() {});
                            },
                            onChanged: (v) {
                              widget.stackedWidgetModel!.fontSize = v;
                              widget.voidCallback!.call();

                              setState(() {});
                            },
                          ).paddingLeft(16),
                          Text('${widget.stackedWidgetModel!.fontSize!.toInt()}' + '%'),
                        ],
                      ),
                      16.height,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Text Color :', style: primaryTextStyle()),
                          8.height,
                          ColorSelectorBottomSheet(
                            list: textColors,
                            selectedColor: widget.stackedWidgetModel!.textColor,
                            onColorSelected: (c) {
                              widget.stackedWidgetModel!.textColor = c;
                              widget.voidCallback!.call();

                              setState(() {});
                            },
                          ),
                        ],
                      ),
                      16.height,
                      8.height,
                      Text('Template Size', style: boldTextStyle()),
                      Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          Slider(
                            value: widget.stackedWidgetModel!.size.validate(value: 16),
                            min: 120.0,
                            max: 300.0,
                            onChangeEnd: (v) {
                              widget.stackedWidgetModel!.size = v;
                              widget.voidCallback!.call();

                              setState(() {});
                            },
                            onChanged: (v) {
                              widget.stackedWidgetModel!.size = v;
                              widget.voidCallback!.call();

                              setState(() {});
                            },
                          ).paddingLeft(16),
                          Text('${widget.stackedWidgetModel!.size!.toInt()}' + '%'),
                        ],
                      ),
                      AppButton(
                        text: 'Remove',
                        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                        onTap: () {
                          finish(context, widget.stackedWidgetModel);
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: boxDecorationWithRoundedCorners(borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Edit Text', style: boldTextStyle()),
                      Icon(Icons.clear, color: Colors.black).onTap(() {
                        finish(context);
                      })
                    ],
                  ).paddingSymmetric(horizontal: 16, vertical: 16),
                ),
              ],
            )
          : Stack(
              alignment: Alignment.topLeft,
              children: [
                SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      32.height,
                      AppTextField(
                        textFieldType: TextFieldType.NAME,
                        controller: _textEditingController,
                        onChanged: (s) async {
                          await 1.seconds.delay;
                          widget.stackedWidgetModel!.value = s;
                          widget.voidCallback!.call();
                        },
                      ).paddingBottom(8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          16.height,
                          Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            children: [
                              Text('Normal', style: boldTextStyle()).onTap(() {
                                widget.stackedWidgetModel!.fontStyle = FontStyle.normal;
                                widget.voidCallback!.call();
                                setState(() {});
                              }),
                              Text('Italic', style: boldTextStyle(fontStyle: FontStyle.italic)).onTap(() {
                                widget.stackedWidgetModel!.fontStyle = FontStyle.italic;
                                widget.voidCallback!.call();

                                setState(() {});
                              }),
                            ],
                          ),
                        ],
                      ).visible(isTextTypeWidget),
                      8.height,
                      if (selectedFontFamily != null && isTextWidget)
                        Row(
                          children: [
                            Text('Font family :', style: primaryTextStyle()),
                            8.width,
                            DropdownButton(
                              isExpanded: true,
                              value: selectedFontFamily,
                              items: fontList.map((e) {
                                return DropdownMenuItem(child: Text(e.fontName!, style: primaryTextStyle(fontFamily: GoogleFonts.getFont(e.fontName!).fontFamily)), value: e);
                              }).toList(),
                              // underline: SizedBox(),
                              onChanged: (FontData? s) {
                                selectedFontFamily = s;

                                widget.stackedWidgetModel!.fontFamily = s!.fontFamily;
                                widget.voidCallback!.call();

                                setState(() {});
                              },
                            ).expand(),
                          ],
                        ),
                      8.height,
                      isStickerWidget ? Text('Size :', style: primaryTextStyle()) : Text('Font Size :', style: primaryTextStyle()),
                      Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          Slider(
                            value: widget.stackedWidgetModel!.size.validate(value: 16),
                            min: 10.0,
                            max: (isStickerWidget) ? 300.0 : 100.0,
                            onChangeEnd: (v) {
                              widget.stackedWidgetModel!.size = v;
                              widget.voidCallback!.call();

                              setState(() {});
                            },
                            onChanged: (v) {
                              widget.stackedWidgetModel!.size = v;
                              widget.voidCallback!.call();

                              setState(() {});
                            },
                          ).paddingLeft(16),
                          Text('${widget.stackedWidgetModel!.size!.toInt()}' + '%'),
                        ],
                      ),
                      8.height.visible(isTextTypeWidget),
                      Text('Background Color :', style: primaryTextStyle()).visible(isTextTypeWidget),
                      8.height.visible(isTextTypeWidget),
                      ColorSelectorBottomSheet(
                        list: backgroundColors,
                        selectedColor: widget.stackedWidgetModel!.backgroundColor,
                        onColorSelected: (c) {
                          widget.stackedWidgetModel!.backgroundColor = c;
                          widget.voidCallback!.call();

                          setState(() {});
                        },
                      ).visible(isTextTypeWidget),
                      16.height.visible(isTextTypeWidget),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Text Color :', style: primaryTextStyle()),
                          8.height,
                          ColorSelectorBottomSheet(
                            list: textColors,
                            selectedColor: widget.stackedWidgetModel!.textColor,
                            onColorSelected: (c) {
                              widget.stackedWidgetModel!.textColor = c;
                              widget.voidCallback!.call();
                              setState(() {});
                            },
                          ),
                        ],
                      ).visible(isTextTypeWidget),
                      16.height,
                      AppButton(
                        text: 'Remove',
                        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                        onTap: () {
                          finish(context, widget.stackedWidgetModel);
                          LiveStream().emit('mIsText', false);
                          LiveStream().emit('appStoreText', false);
                        },
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: boxDecorationWithRoundedCorners(borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Edit Text', style: boldTextStyle()),
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
