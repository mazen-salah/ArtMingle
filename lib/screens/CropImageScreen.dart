import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../components/AdsComponent.dart';
import '../../main.dart';
import '../../services/FileService.dart';
import '../../utils/AdConfigurationConstants.dart';
import '../components/AppBarComponent.dart';
import '../utils/AppPermissionHandler.dart';
import '../utils/Common.dart';
import 'DashboardScreen.dart';

enum AppState { free, picked, cropped }

class CropImageScreen extends StatefulWidget {
  static String tag = '/CompressImageScreen';
  final File? file;

  CropImageScreen({this.file});

  @override
  CropImageScreenState createState() => CropImageScreenState();
}

class CropImageScreenState extends State<CropImageScreen> {
  bool mIsImageSaved = false;

  AppState state = AppState.picked;

  File? imageFile;
  File? originalFile;

  String title = "";

  @override
  void initState() {
    super.initState();
    originalFile = widget.file;

    init();
  }

  Future<void> init() async {
    cropImage(
        imageFile: originalFile!,
        onDone: (file) async {
          state = AppState.cropped;

          imageFile = await saveToDirectory(file);
          if (!disableAdMob) {
            if (isAds == isGoogleAds) {
              if (myInterstitial != null) showInterstitialAd(context);
            }
            if (isAds == isFacebookAds) {
              showFacebookInterstitialAd();
            }
          }
          setState(() {});
          await 1.seconds.delay;
          // finish(context, true);
        }).catchError(log);

    if (!disableAdMob) {
      loadInterstitialAd();
    }
  }

  void changeTitleText() {
    if (state == AppState.free) {
      title = 'Pick Image';
    } else if (state == AppState.picked) {
      title = 'Crop';
    } else if (state == AppState.cropped) {
      title = 'Clear';
    } else {
      title = '';
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  Future<void> save(String path) async {
    checkPermission(context, func: () async {
      await ImageGallerySaver.saveFile(path, name: fileName(path));
      toast("Cropped image saved successfully");
      await 1.seconds.delay;
      DashboardScreen().launch(context, isNewTask: true);
    });
  }

  // onDeviceBack()  async{
  //   // finish(context, true);
  //   return Future.value(true);
  // }

  @override
  Widget build(BuildContext context) {
    changeTitleText();
    return WillPopScope(
      onWillPop: () {
        finish(context, true);
        return Future.value(true);
        //
      },

      child: Scaffold(
        appBar: appBarComponent(
          context: context,
          title: 'Crop Image',
          list: [
            TextButton(
              onPressed: () => save(imageFile!.path),
              child: Text('Save', style: boldTextStyle(color: Colors.white, size: 18)),
            ),
          ],
        ),
        // appBarWidget(
        //   'Crop Image',
        //   backWidget: Icon(Icons.close, color: Colors.black, size: 24).onTap(() {
        //     finish(context, true);
        //   }),
        //   actions: [
        //     TextButton(
        //       onPressed: () => save(imageFile!.path),
        //       child: Text('Save', style: boldTextStyle(color: colorPrimary, size: 18)).withShaderMaskGradient(LinearGradient(colors: [itemGradient1, itemGradient2])),
        //     ),
        //   ]
        // ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  originalFile != null ? Text("Original File", style: boldTextStyle()) : SizedBox(),
                  8.height,
                  originalFile != null ? Image.file(originalFile!, height: (context.height() / 2) - 100) : SizedBox(),
                  8.height,
                  imageFile != null ? Text("Cropped File", style: boldTextStyle()) : SizedBox(),
                  8.height,
                  imageFile != null ? Image.file(imageFile!) : SizedBox(),
                ],
              ),
            ).expand(),
            8.height,
          ],
        ),
      ),
    );
  }
}
