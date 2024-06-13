import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../screens/CollegeMakerScreen.dart';
import '../../screens/CompressImageScreen.dart';
import '../../screens/CropImageScreen.dart';
import '../../screens/PhotoEditScreen.dart';
import '../../screens/ResizeImageScreen.dart';
import '../../screens/TrimVideoScreen.dart';
import '../../services/FileService.dart';
import '../../utils/Colors.dart';

import '../main.dart';
import 'HomeItemWidget.dart';

class HomeItemListWidget extends StatefulWidget {
  static String tag = '/HomeItemListWidget';
  final Function? onUpdate;

  HomeItemListWidget({this.onUpdate});

  @override
  _HomeItemListWidgetState createState() => _HomeItemListWidgetState();
}

class _HomeItemListWidgetState extends State<HomeItemListWidget> {
  void pickImageSource(ImageSource imageSource) {
    pickImage(imageSource: imageSource).then((value) async {
      await PhotoEditScreen(file: value).launch(context, pageRouteAnimation: PageRouteAnimation.Fade, duration: 1000.milliseconds);
    }).catchError((e) {
      log(e.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            HomeItemWidget(
              height: 150,
              width: context.width() / 2 - 16,
              widget: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Ionicons.images_outline, color: Colors.white, size: 28),
                  16.height,
                  Text('Pick Image', style: primaryTextStyle(color: Colors.white)),
                ],
              ),
              onTap: () {
                showInDialog(context, contentPadding: EdgeInsets.zero, builder: (context) {
                  return Container(
                    width: context.width(),
                    padding: EdgeInsets.all(8),
                    decoration: boxDecorationWithShadow(borderRadius: radius(8)),
                    child: Row(
                      // crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        InkWell(
                          onTap: () {
                            finish(context);

                            pickImageSource(ImageSource.gallery);
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              8.height,
                              Icon(Ionicons.image_outline, color: Colors.black, size: 32),
                              Text('Gallery', style: primaryTextStyle(color: Colors.black)).paddingAll(16),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            finish(context);

                            pickImageSource(ImageSource.camera);
                            //var image = ImageSource.camera;
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              8.height,
                              Icon(Ionicons.camera_outline, color: Colors.black, size: 32),
                              Text('Camera', style: primaryTextStyle(color: Colors.black)).paddingAll(16),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                });
              },
            ),
            Column(
              children: [
                HomeItemWidget(
                  width: context.width() / 2 - 32,
                  height: 65,
                  widget: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(MaterialCommunityIcons.crop, color: Colors.white, size: 26),
                      8.width,
                      Text('Crop ', style: primaryTextStyle(color: Colors.white)),
                    ],
                  ),
                  onTap: () async {
                    pickImage().then((value) async {
                      bool res = await CropImageScreen(file: value).launch(context);
                      if (res == true) {
                        widget.onUpdate!.call();
                      }
                    }).catchError((e) {
                      log(e);
                    });
                  },
                ),
                HomeItemWidget(
                  width: context.width() / 2 - 32,
                  height: 65,
                  widget: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.compress, color: Colors.white, size: 24),
                      8.width,
                      Text('Compress', style: primaryTextStyle(color: Colors.white), overflow: TextOverflow.ellipsis),
                    ],
                  ),
                  onTap: () {
                    pickImage().then((value) async {
                      bool res = await CompressImageScreen(file: value).launch(context);
                      if (res == true) {
                        widget.onUpdate!.call();
                      }
                    });
                  },
                ),
              ],
            )
          ],
        ),
        Row(
          children: [
            HomeItemWidget(
              height: 150,
              width: context.width() / 3 - 22,
              widget: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(MaterialCommunityIcons.play_box_outline, color: Colors.white, size: 26),
                  8.height,
                  Text('Trim Video', style: primaryTextStyle(color: Colors.white), textAlign: TextAlign.center),
                ],
              ),
              onTap: () {
                pickVideo().then((value) => TrimVideoScreen(file: value).launch(context)).catchError((error) => log(error.toString()));
              },
            ),
            HomeItemWidget(
              height: 150,
              width: context.width() / 3 - 22,
              widget: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(MaterialCommunityIcons.image_size_select_large, color: Colors.white, size: 26),
                  8.height,
                  Text('Resize', style: primaryTextStyle(color: Colors.white), textAlign: TextAlign.center),
                ],
              ),
              onTap: () {
                pickImage().then((value) async {
                  bool res = await ResizeImageScreen(file: value).launch(context);
                  if (res == true) {
                    widget.onUpdate!.call();
                  }
                });
              },
            ),
            HomeItemWidget(
              height: 150,
              width: context.width() / 3 - 22,
              widget: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(MaterialCommunityIcons.view_dashboard_outline, color: Colors.white),
                  8.height,
                  Text('Make Collage ', style: primaryTextStyle(color: Colors.white), textAlign: TextAlign.center),
                ],
              ),
              onTap: () async {
                bool? isConfirm = false;
                await showConfirmDialogCustom(context, title: 'Choose at least 2 and maximum 9 images', positiveText: 'Choose', negativeText: 'Cancel', primaryColor: colorPrimary,
                    onAccept: (context) {
                  isConfirm = true;
                });
                if (isConfirm ?? true) {
                  pickMultipleImage().then((value) async {
                    if (value.length >= 2 && value.length <= 9) {
                      appStore.clearCollegeImageList();

                      ///compress all image before making college photo
                      await Future.forEach(value, (File? e) async {
                        await FlutterNativeImage.compressImage(e!.path, quality: 70).then((File? f) {
                          if (f != null) {
                            appStore.addCollegeImages(f);
                          }
                        });
                      });
                      await showInDialog(context, builder: (c) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AppButton(
                              width: context.width(),
                              padding: EdgeInsets.zero,
                              color: colorPrimary,
                              child: Text('Default Collage', style: boldTextStyle(color: Colors.white)),
                              onTap: () {
                                finish(context);
                                CollegeMakerScreen(isAutomatic: true).launch(context);
                              },
                            ),
                            4.height,
                            AppButton(
                              width: context.width(),
                              padding: EdgeInsets.zero,
                              color: colorPrimary,
                              child: Text('Manual Collage', style: boldTextStyle(color: Colors.white)),
                              onTap: () {
                                finish(context);
                                CollegeMakerScreen(isAutomatic: false).launch(context);
                              },
                            ),
                          ],
                        );
                      });
                    } else {
                      toast('Choose at least 2 and maximum 9 images');
                    }
                  }).catchError((error) {
                    log(error.toString());
                  });
                }
              },
            ),
          ],
        )
      ],
    ).paddingAll(8);
  }
}
