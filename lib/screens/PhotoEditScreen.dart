import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:zoom_widget/zoom_widget.dart';
import '../../components/AdsComponent.dart';
import '../../components/BlurSelectorBottomSheet.dart';
import '../../components/BottomBarItemWidget.dart';
import '../../components/ColorSelectorBottomSheet.dart';
import '../../components/EmojiPickerBottomSheet.dart';
import '../../components/FilterSelectionWidget.dart';
import '../../components/FrameSelectionWidget.dart';
import '../../components/ImageFilterWidget.dart';
import '../../components/SignatureWidget.dart';
import '../../components/StackedWidgetComponent.dart';
import '../../components/StickerPickerBottomSheet.dart';
import '../../components/TextEditorDialog.dart';
import '../../models/ColorFilterModel.dart';
import '../../models/StackedWidgetModel.dart';
import '../../services/FileService.dart';
import '../../utils/AdConfigurationConstants.dart';
import '../../utils/Colors.dart';
import '../../utils/Constants.dart';
import '../../utils/SignatureLibWidget.dart';
import 'package:screenshot/screenshot.dart';
import '../components/TextTemplatePickerBottomSheet.dart';
import '../main.dart';
import '../models/BorderModel.dart';
import '../models/UndoModel.dart';
import '../utils/AppPermissionHandler.dart';
import '../utils/Common.dart';
import 'DashboardScreen.dart';
import 'RemoveBackgroundScreen.dart';

class PhotoEditScreen extends StatefulWidget {
  static String tag = '/PhotoEditScreen';
  final File? file;
  final bool isFreePhoto;
  final String? freeImage;

  PhotoEditScreen({this.file, this.isFreePhoto = false, this.freeImage});

  @override
  PhotoEditScreenState createState() => PhotoEditScreenState();
}

class PhotoEditScreenState extends State<PhotoEditScreen> {
  final GlobalKey scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey key = GlobalKey<PhotoEditScreenState>();
  final ScrollController scrollController = ScrollController();

  DateTime? currentBackPressTime;

  /// Google Ads
  RewardedAd? rewardedAd;
  InterstitialAd? myInterstitial;
  bool mIsImageSaved = false;

  /// Used to save edited image on storage
  ScreenshotController screenshotController = ScreenshotController();
  final GlobalKey screenshotKey = GlobalKey();
  final GlobalKey imageKey = GlobalKey();
  final GlobalKey galleryKey = GlobalKey();

  /// Used to draw on image
  SignatureController signatureController = SignatureController(penStrokeWidth: 5, penColor: Colors.green);
  List<Offset> points = [];

  /// Texts on image
  List<StackedWidgetModel> mStackedWidgetList = [];

  // List<UndoModel> appStore.mStackedWidgetListundo1 = [];
  // List<UndoModel> mStackedWidgetListundo = [];

  /// Image file picked from previous screen
  File? originalFile;
  File? croppedFile;

  /// Image file picked from previous screen
  String? originalFileFree;
  String? croppedFileFree;
  String? text;
  double topWidgetHeight = 50, bottomWidgetHeight = 80, blur = 0;

  /// Variables used to show or hide bottom widgets
  bool mIsPenColorVisible = false, mIsFilterViewVisible = false, mIsBlurVisible = false, mIsFrameVisible = false;
  bool mIsBrightnessSliderVisible = false, mIsSaturationSliderVisible = false, mIsHueSliderVisible = false, mIsContrastSliderVisible = false;
  bool mIsTextstyle = false;
  bool mIsTextColor = false;
  bool mIsTextBgColor = false;
  bool mIsTextSize = false;
  bool mIsMoreConfigWidgetVisible = true;
  bool mIsPenEnabled = false;
  bool mShowBeforeImage = false;
  bool mIsPremium = false;
  bool mIsText = false;
  bool mIsBorderSliderVisible = false;

  /// Selected color filter
  ColorFilterModel? filter;

  double brightness = 0.0, saturation = 0.0, hue = 0.0, contrast = 0.0;

  /// Selected frame
  String? frame;

  ///Border
  bool isOuterBorder = true;
  double outerBorderwidth = 0.0;
  Color outerBorderColor = Colors.black;
  double innerBorderwidth = 0.0;
  Color innerBorderColor = Colors.black;
  bool? permissionStatus;

  double? imageHeight;
  double? imageWidth;

  void pickImageSource(ImageSource imageSource) {
    pickImage(imageSource: imageSource).then((value) async {
      mStackedWidgetList.add(
        StackedWidgetModel(file: value, widgetType: WidgetTypeImage, offset: Offset(100, 100), size: 100),
      );
      appStore.addUndoList(
        undoModel: UndoModel(
          type: 'mStackedWidgetList',
          widget: StackedWidgetModel(file: value, widgetType: WidgetTypeImage, offset: Offset(100, 100), size: 100),
        ),
      );
      RemoveBackgroundScreen(file: value).launch(context);
      setState(() {});
    }).catchError((e) {
      log(e.toString());
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) => getImageSize());
    setState(() {});

    super.initState();
    init();
  }

  Future<void> getImageSize() async {
    await 2.seconds.delay;
    imageHeight = imageKey.currentContext!.size!.height;
    imageWidth = imageKey.currentContext!.size!.width;
    log(imageHeight);
    log(imageWidth);
    if (imageHeight.validate().toInt() == 0) {
      imageHeight = context.height();
    }
    if (imageWidth.validate().toInt() == 0) {
      imageWidth = context.width();
    }
    setState(() {});
  }

  Future<void> init() async {
    LiveStream().on('mIsText', (v) {
      if (appStore.mStackedWidgetListundo1.last.type == 'text') {
        mIsText = true;
      } else if (v == false) {
        mIsText = false;
      }

      setState(() {});
    });
    LiveStream().on('appStoreText', (v) {
      if (appStore.mStackedWidgetListundo1.last.type == 'text') {
        mIsText = true;
      } else if (v == false) {
        appStore.isText = false;
      }

      setState(() {});
    });

    if (!disableAdMob) {
      if (isAds == isGoogleAds) {
        loadInterstitialAd();
      } else {
        loadFaceBookInterstitialAd();
      }
    }

    if (widget.isFreePhoto) {
      originalFileFree = widget.freeImage;
      croppedFileFree = widget.freeImage;
    } else {
      originalFile = widget.file;
      croppedFile = widget.file;
    }

    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
        mIsMoreConfigWidgetVisible = false;
      } else {
        mIsMoreConfigWidgetVisible = true;
      }

      setState(() {});
    });

    if (!disableAdMob) {
      loadInterstitialAd();
    }
  }

  Future<void> checkPermissionAndCaptureImage() async {
    checkPermission(context, func: () async {
      capture().whenComplete(() => log("done"));
    });
  }

  Future<void> capture() async {
    appStore.setLoading(true);

    mIsBlurVisible = false;
    mIsFilterViewVisible = false;
    mIsFrameVisible = false;
    mIsPenColorVisible = false;
    mIsBrightnessSliderVisible = false;
    mIsSaturationSliderVisible = false;
    mIsHueSliderVisible = false;
    mIsContrastSliderVisible = false;
    setState(() {});

    await screenshotController.captureAndSave(await getFileSavePath(), delay: 1.seconds).then((value) async {
      log('Saved : $value');

      // save in gallery
      // final bytes = await File(value!).readAsBytes();
      // await ImageGallerySaver.saveImage(bytes.buffer.asUint8List(), name: fileName(value));

      await ImageGallerySaver.saveFile(value!, name: fileName(value));
      toast('Saved');
      mIsImageSaved = true;

      if (!disableAdMob && isAds == isGoogleAds) {
        if (myInterstitial != null) {
          myInterstitial!.show().then((value) {
            myInterstitial?.dispose();
          });
        } else {
          showInterstitialAd(context);
        }
      }
      if (!disableAdMob && isAds == isFacebookAds) {
        showFacebookInterstitialAd();
      }
    }).catchError((e) {
      log(e);
    });

    appStore.setLoading(false);
    // pop();
    DashboardScreen().launch(context, isNewTask: true);
  }
  List<Color> convertDoublesToColors(List<double> values) {
    List<Color> colors = [];

    for (double value in values) {
      // Assuming the double value is between 0 and 1
      // You may need to adjust the logic based on your specific requirements

      // Scale the double value to a range between 0 and 255
      int scaledValue = (value * 255).round();

      // Create a color with the scaled value for red, green, and blue
      Color color = Color.fromARGB(255, scaledValue, scaledValue, scaledValue);
      colors.add(color);
    }

    return colors;
  }


  void onEraserClick() {
    // List<double> doubleValues = [0.39, 0.769, 0.189, 0.0, 0.0, 0.349, 0.686, 0.168, 0.0, 0.0, 0.272, 0.534, 0.131, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0]; // Example double value
    // List<Color> colors = convertDoublesToColors(doubleValues);
    // print("COLOR CODE IS +++?"+colors.toString()); // Print the color code

    showConfirmDialogCustom(context, title: 'Do you want to clear?', primaryColor: colorPrimary, positiveText: 'Yes', negativeText: 'No', onAccept: (context) {
      mIsBlurVisible = false;
      mIsFilterViewVisible = false;
      mIsFrameVisible = false;
      mIsPenColorVisible = false;
      mIsBrightnessSliderVisible = false;
      mIsSaturationSliderVisible = false;
      mIsHueSliderVisible = false;
      mIsContrastSliderVisible = false;
      mIsBorderSliderVisible = false;

      /// Clear signature
      signatureController.clear();
      points.clear();

      /// Clear stacked widgets
      mStackedWidgetList.clear();

      /// Clear filter
      filter = null;

      /// Clear blur effect
      blur = 0;

      /// Clear frame
      frame = null;

      /// Clear brightness, contrast, saturation, hue
      brightness = 0.0;
      saturation = 0.0;
      hue = 0.0;
      contrast = 0.0;

      ///Border
      outerBorderwidth = 0.0;
      innerBorderwidth = 0.0;

      appStore.mStackedWidgetListundo = [];
      appStore.mStackedWidgetListundo1 = [];

      setState(() {});
    });

  }

  Future<void> onTextClick() async {
    mIsBlurVisible = false;
    mIsFilterViewVisible = false;
    mIsFrameVisible = false;
    mIsPenColorVisible = false;
    mIsBrightnessSliderVisible = false;
    mIsSaturationSliderVisible = false;
    mIsHueSliderVisible = false;
    mIsContrastSliderVisible = false;
    mIsText = true;
    appStore.isText = true;
    mIsBorderSliderVisible = false;

    setState(() {});

    text = await showInDialog(context, builder: (_) => TextEditorDialog());
    // String? text = await showInDialog(context, builder: (_) => TextEditorDialog());

    if (text.validate().isNotEmpty) {
      var stackedWidgetModel = StackedWidgetModel(
        value: text,
        widgetType: WidgetTypeText,
        offset: Offset(100, 100),
        size: 20,
        backgroundColor: Colors.transparent,
        textColor: Colors.white,
      );
      mStackedWidgetList.add(
        stackedWidgetModel,
      );
      appStore.addUndoList(undoModel: UndoModel(type: 'mStackedWidgetList', widget: stackedWidgetModel));

      setState(() {});
    } else {
      // print("In else mis Text false");
      // mIsText = false;
      // appStore.isText = false;
      setState(() {});
    }
  }

  Future<void> onNeonLightClick() async {
    mIsBlurVisible = false;
    mIsFilterViewVisible = false;
    mIsFrameVisible = false;
    mIsPenColorVisible = false;
    mIsBrightnessSliderVisible = false;
    mIsSaturationSliderVisible = false;
    mIsHueSliderVisible = false;
    mIsContrastSliderVisible = false;
    mIsText = true;
    appStore.isText = true;
    mIsBorderSliderVisible = false;

    setState(() {});

    text = await showInDialog(context, builder: (_) => TextEditorDialog());

    if (text.validate().isNotEmpty) {
      var stackedWidgetModel = StackedWidgetModel(
        value: text,
        widgetType: WidgetTypeNeon,
        offset: Offset(100, 100),
        size: 40,
        backgroundColor: Colors.transparent,
        textColor: getColorFromHex('#FF7B00AB'),
      );
      mStackedWidgetList.add(stackedWidgetModel);
      appStore.addUndoList(undoModel: UndoModel(type: 'mStackedWidgetList', widget: stackedWidgetModel));
      setState(() {});
    }
  }

  Future<void> onEmojiClick() async {
    mIsBlurVisible = false;
    mIsFilterViewVisible = false;
    mIsFrameVisible = false;
    mIsPenColorVisible = false;
    mIsBrightnessSliderVisible = false;
    mIsSaturationSliderVisible = false;
    mIsHueSliderVisible = false;
    mIsContrastSliderVisible = false;
    mIsBorderSliderVisible = false;

    setState(() {});

    appStore.setLoading(true);
    await 300.milliseconds.delay;

    String? emoji = await showModalBottomSheet(context: context, backgroundColor: Colors.transparent, builder: (_) => EmojiPickerBottomSheet());

    if (emoji.validate().isNotEmpty) {
      var stackedWidgetModel = StackedWidgetModel(
        value: emoji,
        widgetType: WidgetTypeEmoji,
        offset: Offset(100, 100),
        size: 50,
      );
      mStackedWidgetList.add(stackedWidgetModel);
      appStore.addUndoList(undoModel: UndoModel(type: 'mStackedWidgetList', widget: stackedWidgetModel));

      setState(() {});
    }
  }

  Future<void> onStickerClick() async {
    mIsBlurVisible = false;
    mIsFilterViewVisible = false;
    mIsFrameVisible = false;
    mIsPenColorVisible = false;
    mIsBrightnessSliderVisible = false;
    mIsSaturationSliderVisible = false;
    mIsHueSliderVisible = false;
    mIsContrastSliderVisible = false;
    mIsBorderSliderVisible = false;

    setState(() {});

    appStore.setLoading(true);
    await 300.milliseconds.delay;

    String? sticker = await showModalBottomSheet(context: context, backgroundColor: Colors.transparent, builder: (_) => StickerPickerBottomSheet());

    if (sticker.validate().isNotEmpty) {
      var stackedWidgetModel = StackedWidgetModel(value: sticker, widgetType: WidgetTypeSticker, offset: Offset(100, 100), size: 100);
      mStackedWidgetList.add(stackedWidgetModel);
      appStore.addUndoList(undoModel: UndoModel(type: 'mStackedWidgetList', widget: stackedWidgetModel));
      setState(() {});
    }
  }

  Future<void> onImageClick() async {
    mIsBlurVisible = false;
    mIsFilterViewVisible = false;
    mIsFrameVisible = false;
    mIsPenColorVisible = false;
    mIsBrightnessSliderVisible = false;
    mIsSaturationSliderVisible = false;
    mIsHueSliderVisible = false;
    mIsContrastSliderVisible = false;
    mIsBorderSliderVisible = false;

    setState(() {});

    // appStore.setLoading(true);
    await 300.milliseconds.delay;
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
  }

  void onTextStyle() {
    mIsTextstyle = !mIsTextstyle;
    mIsTextColor = false;
    mIsTextBgColor = false;
    mIsTextSize = false;
    setState(() {});
  }

  void onPenClick() {
    mIsBlurVisible = false;
    mIsFilterViewVisible = false;
    mIsFrameVisible = false;
    mIsBrightnessSliderVisible = false;
    mIsSaturationSliderVisible = false;
    mIsHueSliderVisible = false;
    mIsContrastSliderVisible = false;
    mIsBorderSliderVisible = false;

    mIsPenColorVisible = !mIsPenColorVisible;
    setState(() {});
  }

  void onBlurClick() {
    mIsFilterViewVisible = false;
    mIsFrameVisible = false;
    mIsPenColorVisible = false;
    mIsBrightnessSliderVisible = false;
    mIsSaturationSliderVisible = false;
    mIsHueSliderVisible = false;
    mIsContrastSliderVisible = false;
    mIsBorderSliderVisible = false;

    mIsBlurVisible = !mIsBlurVisible;

    setState(() {});
  }

  Future<void> onFilterClick() async {
    mIsFrameVisible = false;
    mIsPenColorVisible = false;
    mIsBlurVisible = false;
    mIsBrightnessSliderVisible = false;
    mIsSaturationSliderVisible = false;
    mIsHueSliderVisible = false;
    mIsContrastSliderVisible = false;
    mIsBorderSliderVisible = false;

    mIsFilterViewVisible = !mIsFilterViewVisible;

    setState(() {});
  }

  Future<void> onShapeClick() async {
    mIsFrameVisible = false;
    mIsPenColorVisible = false;
    mIsBlurVisible = false;
    mIsBrightnessSliderVisible = false;
    mIsSaturationSliderVisible = false;
    mIsHueSliderVisible = false;
    mIsContrastSliderVisible = false;
    mIsFilterViewVisible = false;
    mIsBorderSliderVisible = false;

    var stackedWidgetModel = StackedWidgetModel(widgetType: WidgetTypeContainer, offset: Offset(100, 100), size: 120, shape: BoxShape.circle);
    mStackedWidgetList.add(stackedWidgetModel);
    appStore.addUndoList(undoModel: UndoModel(type: 'mStackedWidgetList', widget: stackedWidgetModel));

    setState(() {});
  }

  Future<void> onTextTemplet() async {
    mIsFrameVisible = false;
    mIsPenColorVisible = false;
    mIsBlurVisible = false;
    mIsBrightnessSliderVisible = false;
    mIsSaturationSliderVisible = false;
    mIsHueSliderVisible = false;
    mIsContrastSliderVisible = false;
    mIsFilterViewVisible = false;
    mIsBorderSliderVisible = false;

    String? textTamplet = await showModalBottomSheet(context: context, backgroundColor: Colors.transparent, builder: (_) => TextTemplatePickerBottomSheet());
    if (textTamplet.validate().isNotEmpty) {
      String? text = await showInDialog(context, builder: (_) => TextEditorDialog());
      var stackedWidgetModel = StackedWidgetModel(widgetType: WidgetTypeTextTemplate, imageName: textTamplet, offset: Offset(100, 100), size: 120, fontSize: 16, value: text);
      mStackedWidgetList.add(stackedWidgetModel);
      appStore.addUndoList(undoModel: UndoModel(type: 'mStackedWidgetList', widget: stackedWidgetModel));
    }
    setState(() {});
  }

  Future<void> onBorderSliderClick() async {
    mIsPenColorVisible = false;
    mIsBlurVisible = false;
    mIsFilterViewVisible = false;
    mIsFrameVisible = false;
    mIsSaturationSliderVisible = false;
    mIsHueSliderVisible = false;
    mIsContrastSliderVisible = false;
    mIsBrightnessSliderVisible = false;
    mIsBorderSliderVisible = !mIsBorderSliderVisible;

    setState(() {});
  }

  Future<void> onFrameClick() async {
    if (!getBoolAsync(IS_FRAME_REWARDED)) {
      mIsPenColorVisible = false;
      mIsBlurVisible = false;
      mIsFilterViewVisible = false;
      mIsBrightnessSliderVisible = false;
      mIsSaturationSliderVisible = false;
      mIsHueSliderVisible = false;
      mIsContrastSliderVisible = false;
      mIsBorderSliderVisible = false;
      mIsFrameVisible = !mIsFrameVisible;

      setState(() {});
    } else {
      /*if (rewardedAd != null && await rewardedAd.isLoaded()) {
        rewardedAd.show();
        toast('Showing reward ad');
      }*/
    }
  }

  Future<void> onBrightnessSliderClick() async {
    mIsPenColorVisible = false;
    mIsBlurVisible = false;
    mIsFilterViewVisible = false;
    mIsFrameVisible = false;
    mIsSaturationSliderVisible = false;
    mIsHueSliderVisible = false;
    mIsContrastSliderVisible = false;
    mIsBorderSliderVisible = false;

    mIsBrightnessSliderVisible = !mIsBrightnessSliderVisible;

    setState(() {});
  }

  Future<void> onSaturationSliderClick() async {
    mIsPenColorVisible = false;
    mIsBlurVisible = false;
    mIsFilterViewVisible = false;
    mIsFrameVisible = false;
    mIsBrightnessSliderVisible = false;
    mIsHueSliderVisible = false;
    mIsContrastSliderVisible = false;
    mIsBorderSliderVisible = false;

    mIsSaturationSliderVisible = !mIsSaturationSliderVisible;

    setState(() {});
  }

  Future<void> onHueSliderClick() async {
    mIsPenColorVisible = false;
    mIsBlurVisible = false;
    mIsFilterViewVisible = false;
    mIsFrameVisible = false;
    mIsBrightnessSliderVisible = false;
    mIsSaturationSliderVisible = false;
    mIsContrastSliderVisible = false;
    mIsBorderSliderVisible = false;

    mIsHueSliderVisible = !mIsHueSliderVisible;

    setState(() {});
  }

  Future<void> onContrastSliderClick() async {
    mIsPenColorVisible = false;
    mIsBlurVisible = false;
    mIsFilterViewVisible = false;
    mIsFrameVisible = false;
    mIsBrightnessSliderVisible = false;
    mIsSaturationSliderVisible = false;
    mIsHueSliderVisible = false;
    mIsBorderSliderVisible = false;

    mIsContrastSliderVisible = !mIsContrastSliderVisible;

    setState(() {});
  }

  // onDeviceBack() async {
  //   DateTime now = DateTime.now();
  //   if (currentBackPressTime == null || now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
  //     currentBackPressTime = now;
  //     toast('Your edited image will be lost\nPress back again to go back');
  //     return Future.value(false);
  //   }
  //   return Future.value(true);
  // }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    LiveStream().dispose('mIsText');

    super.dispose();
    signatureController.dispose();
    scrollController.dispose();
    rewardedAd?.dispose();
    myInterstitial?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          DateTime now = DateTime.now();
          if (currentBackPressTime == null || now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
            currentBackPressTime = now;
            toast('Your edited image will be lost\nPress back again to go back');
            return Future.value(false);
          }
          return Future.value(true);
        },
        // PopScope(
        //   canPop: true,
        //   onPopInvoked: (bool didPop) async {
        //     onDeviceBack();
        //   },
        child: Scaffold(
          key: scaffoldKey,
          resizeToAvoidBottomInset: false,
          body: Stack(
            children: [
              Column(
                children: [
                  Container(
                    height: topWidgetHeight,
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                showConfirmDialogCustom(context, title: 'You edited image will be lost', primaryColor: colorPrimary, positiveText: 'Ok', negativeText: 'Cancel',
                                    onAccept: (BuildContext context) async {
                                  mIsText = false;
                                  appStore.isText = false;
                                  Navigator.pop(context);
                                });
                              },
                              icon: Icon(Icons.close),
                            ),
                            IconButton(
                                    onPressed: () {
                                      if (appStore.mStackedWidgetListundo1.last.type == 'mStackedWidgetList') {
                                        mIsText = false;
                                        appStore.isText = false;
                                        mStackedWidgetList.removeLast();
                                      } else if (appStore.mStackedWidgetListundo1.last.type == 'filter') {
                                        filter = null;
                                      } else if (appStore.mStackedWidgetListundo1.last.type == 'blur') {
                                        blur = 0;
                                      } else if (appStore.mStackedWidgetListundo1.last.type == 'frame') {
                                        frame = null;
                                      } else if (appStore.mStackedWidgetListundo1.last.type == 'brightness') {
                                        brightness = 0;
                                      } else if (appStore.mStackedWidgetListundo1.last.type == 'saturation') {
                                        saturation = 0;
                                      } else if (appStore.mStackedWidgetListundo1.last.type == 'hue') {
                                        hue = 0;
                                      } else if (appStore.mStackedWidgetListundo1.last.type == 'contrast') {
                                        contrast = 0;
                                      } else if (appStore.mStackedWidgetListundo1.last.type == 'border') {
                                        // print("------------------------------------------_____________________________");
                                        // print("++======++=+=+====+=+=+=+=+=+=+=+== ${appStore.mStackedWidgetListundo1.last.border!.type!}");
                                        // print("++======++=+=+====+=+=+=+=+=+=+=+== ${appStore.mStackedWidgetListundo1.last.border!.width!}");
                                        // print("++======++=+=+====+=+=+=+=+=+=+=+== ${appStore.mStackedWidgetListundo1.last.border!.borderColor!}");
                                        if (appStore.mStackedWidgetListundo1.last.border!.type == 'outer') {
                                          outerBorderwidth = appStore.mStackedWidgetListundo1.last.border!.width!;
                                          outerBorderColor = appStore.mStackedWidgetListundo1.last.border!.borderColor!;
                                        } else {
                                          innerBorderwidth = appStore.mStackedWidgetListundo1.last.border!.width!;
                                          innerBorderColor = appStore.mStackedWidgetListundo1.last.border!.borderColor!;
                                        }
                                      }
                                      appStore.addRedoList(undoModel: appStore.mStackedWidgetListundo1.last);
                                      appStore.removeUndoList();
                                      setState(() {});
                                    },
                                    icon: Icon(Icons.undo))
                                .visible(appStore.mStackedWidgetListundo1.length != 0),
                            IconButton(
                                    onPressed: () {
                                      // mStackedWidgetList.add(mStackedWidgetListundo.last);
                                      // mStackedWidgetListundo.removeLast();
                                      if (appStore.mStackedWidgetListundo.last.type == 'mStackedWidgetList') {
                                        mStackedWidgetList.add(appStore.mStackedWidgetListundo.last.widget!);
                                        if (appStore.mStackedWidgetListundo.last.type == 'text') {
                                          mIsText = true;
                                          appStore.isText = true;
                                        }
                                      } else if (appStore.mStackedWidgetListundo.last.type == 'filter') {
                                        filter = appStore.mStackedWidgetListundo.last.filter;
                                      } else if (appStore.mStackedWidgetListundo.last.type == 'blur') {
                                        blur = appStore.mStackedWidgetListundo.last.number!;
                                      } else if (appStore.mStackedWidgetListundo.last.type == 'frame') {
                                        frame = appStore.mStackedWidgetListundo.last.data;
                                      } else if (appStore.mStackedWidgetListundo.last.type == 'brightness') {
                                        brightness = appStore.mStackedWidgetListundo.last.number!;
                                      } else if (appStore.mStackedWidgetListundo.last.type == 'saturation') {
                                        saturation = appStore.mStackedWidgetListundo.last.number!;
                                      } else if (appStore.mStackedWidgetListundo.last.type == 'hue') {
                                        hue = appStore.mStackedWidgetListundo.last.number!;
                                      } else if (appStore.mStackedWidgetListundo.last.type == 'contrast') {
                                        contrast = appStore.mStackedWidgetListundo.last.number!;
                                      } else if (appStore.mStackedWidgetListundo.last.type == 'border') {
                                        // print("++======++=+=+====+=+=+=+=+=+=+=+== ${appStore.mStackedWidgetListundo.last.border!.type!}");
                                        // print("++======++=+=+====+=+=+=+=+=+=+=+== ${appStore.mStackedWidgetListundo.last.border!.width!}");
                                        // print("++======++=+=+====+=+=+=+=+=+=+=+== ${appStore.mStackedWidgetListundo.last.border!.borderColor!}");
                                        if (appStore.mStackedWidgetListundo.last.border!.type == 'outer') {
                                          outerBorderwidth = appStore.mStackedWidgetListundo.last.border!.width!;
                                          outerBorderColor = appStore.mStackedWidgetListundo.last.border!.borderColor!;
                                        } else {
                                          innerBorderwidth = appStore.mStackedWidgetListundo.last.border!.width!;
                                          innerBorderColor = appStore.mStackedWidgetListundo.last.border!.borderColor!;
                                        }
                                      }
                                      appStore.addUndoList(undoModel: appStore.mStackedWidgetListundo.last);
                                      appStore.removeRedoList();
                                      setState(() {});
                                    },
                                    icon: Icon(Icons.redo))
                                .visible(appStore.mStackedWidgetListundo.length != 0)
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (!widget.isFreePhoto)
                              IconButton(
                                padding: EdgeInsets.zero,
                                icon: Icon(Icons.crop),
                                onPressed: () async {
                                  if (widget.isFreePhoto) {
                                    cropImage(
                                        isFreePhoto: widget.isFreePhoto,
                                        networkImage: originalFileFree!,
                                        onDone: (file) {
                                          croppedFile = file;
                                          getImageSize();
                                          setState(() {});
                                        }).catchError(log);
                                  } else {
                                    cropImage(
                                        imageFile: originalFile!,
                                        onDone: (file) {
                                          croppedFile = file;
                                          getImageSize();
                                          setState(() {});
                                        }).catchError(log);
                                  }
                                },
                              ).withTooltip(msg: 'Crop'),
                            // 0.width,
                            // GestureDetector(
                            //   onTap: () => log('tap'),
                            //   onTapDown: (v) {
                            //     mShowBeforeImage = true;
                            //     setState(() {});
                            //   },
                            //   onTapUp: (v) {
                            //     mShowBeforeImage = false;
                            //     setState(() {});
                            //   },
                            //   onTapCancel: () {
                            //     mShowBeforeImage = false;
                            //     setState(() {});
                            //   },
                            //   child: Icon(Icons.compare_rounded).paddingAll(0),
                            // ),
                            // 16.width,
                            Text(mIsText ? 'Done' : 'Save', style: boldTextStyle(color: colorPrimary))
                                .paddingSymmetric(horizontal: 16, vertical: 8)
                                .withShaderMaskGradient(LinearGradient(colors: [itemGradient1, itemGradient2]))
                                .onTap(() async {
                              mIsText
                                  ? setState(() {
                                      mIsText = false;
                                      appStore.isText = false;
                                      appStore.isText = false;
                                      mIsTextstyle = false;
                                      mIsTextColor = false;
                                      mIsTextBgColor = false;
                                      mIsTextSize = false;
                                    })
                                  : checkPermissionAndCaptureImage();
                            }, borderRadius: radius())
                          ],
                        ),
                      ],
                    ).paddingTop(0),
                  ),
                  Stack(
                    alignment: AlignmentDirectional.center,
                    children: [
                      // This widget will be saved as edited Image
                      Screenshot(
                        controller: screenshotController,
                        key: screenshotKey,
                        child: SizedBox(
                          height: imageHeight,
                          width: imageWidth,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              (filter != null && filter!.matrix != null)
                                  ? ColorFiltered(
                                      colorFilter: ColorFilter.matrix(filter!.matrix!),
                                      child: Center(
                                        child: ImageFilterWidget(
                                          brightness: brightness,
                                          saturation: saturation,
                                          hue: hue,
                                          contrast: contrast,
                                          child: widget.isFreePhoto ? cachedImage(croppedFileFree!, fit: BoxFit.fitWidth) : Image.file(croppedFile!, fit: BoxFit.fitWidth),
                                        ),
                                      ),
                                    )
                                  : Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(border: Border.all(width: outerBorderwidth, color: outerBorderColor)),
                                          child: ImageFilterWidget(
                                            brightness: brightness,
                                            saturation: saturation,
                                            hue: hue,
                                            contrast: contrast,
                                            child: Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                widget.isFreePhoto ? cachedImage(croppedFileFree!, fit: BoxFit.fitWidth, key: imageKey) : Image.file(croppedFile!, fit: BoxFit.fitWidth, key: imageKey),
                                                Container(decoration: BoxDecoration(border: Border.all(color: innerBorderColor.withOpacity(0.5), width: innerBorderwidth)))
                                              ],
                                            ),
                                          ),
                                        ),
                                        if (filter != null && filter!.color != null)
                                          Container(
                                            height: imageHeight,
                                            width: imageWidth,
                                            color: Colors.black12,
                                          ).withShaderMaskGradient(
                                            LinearGradient(colors: filter!.color!, begin: Alignment.topLeft, end: Alignment.bottomRight),
                                            blendMode: BlendMode.srcOut,
                                          ),
                                      ],
                                    ),
                              ClipRRect(
                                child: BackdropFilter(
                                  filter: ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                                  child: Container(alignment: Alignment.center, color: Colors.grey.withOpacity(0.1)),
                                ),
                              ),
                              /*(filter != null && filter!.color != null)
                                ? Container(
                                    //height: context.height(),
                                    width: context.width(),
                                    color: Colors.black12,
                                    child: SizedBox(),
                                  ).withShaderMaskGradient(
                                    LinearGradient(colors: filter!.color!, begin: Alignment.topLeft, end: Alignment.bottomRight),
                                    blendMode: BlendMode.srcOut,
                                  )
                                : SizedBox(),*/
                              frame != null
                                  ? Container(
                                      color: Colors.black12,
                                      child: Image.asset(frame!, fit: BoxFit.fill, height: context.height(), width: context.width()),
                                    )
                                  : SizedBox(),
                              IgnorePointer(
                                ignoring: !mIsPenEnabled,
                                child: SignatureWidget(
                                  signatureController: signatureController,
                                  points: points,
                                  width: context.width(),
                                  height: context.height() * 0.8,
                                ),
                              ),
                              StackedWidgetComponent(mStackedWidgetList),
                            ],
                          ).center(),
                        ),
                      ),

                      /// Show preview of edited image before save
                      if (widget.isFreePhoto) cachedImage(croppedFileFree!, fit: BoxFit.fitWidth, key: imageKey).visible(mShowBeforeImage),
                      if (!widget.isFreePhoto) Image.file(croppedFile!, fit: BoxFit.cover).visible(!widget.isFreePhoto).visible(mShowBeforeImage),
                    ],
                  ).expand(),
                  Column(
                    children: [
                      if (mIsBrightnessSliderVisible)
                        AnimatedContainer(
                          duration: Duration(milliseconds: 200),
                          height: mIsBrightnessSliderVisible ? 60 : 0,
                          width: context.width(),
                          // color: Colors.grey.shade100,
                          child: Container(
                            color: Colors.white38,
                            height: 60,
                            child: Row(
                              children: [
                                8.width,
                                Text('Brightness'),
                                8.width,
                                Slider(
                                  min: 0.0,
                                  max: 1.0,
                                  onChanged: (d) {
                                    brightness = d;
                                    setState(() {});
                                  },
                                  value: brightness,
                                  onChangeEnd: (d) {
                                    appStore.addUndoList(undoModel: UndoModel(type: 'brightness', number: d));
                                    setState(() {});
                                  },
                                ).expand(),
                              ],
                            ),
                          ),
                        ),
                      if (mIsPenColorVisible)
                        AnimatedContainer(
                          duration: Duration(milliseconds: 200),
                          height: mIsPenColorVisible ? 60 : 0,
                          // color: Colors.grey.shade100,
                          width: context.width(),
                          child: Row(
                            children: [
                              Switch(
                                value: mIsPenEnabled,
                                onChanged: (b) {
                                  mIsPenEnabled = b;
                                  mIsPenColorVisible = false;
                                  setState(() {});
                                },
                              ),
                              ColorSelectorBottomSheet(
                                list: penColors,
                                onColorSelected: (Color color) {
                                  List<Point> tempPoints = signatureController.points;
                                  signatureController = SignatureController(penStrokeWidth: 4, penColor: color);

                                  tempPoints.forEach((element) {
                                    signatureController.addPoint(element);
                                  });

                                  mIsPenColorVisible = false;
                                  mIsPenEnabled = true;

                                  setState(() {});
                                },
                              ),
                            ],
                          ),
                        ),
                      if (mIsTextColor && !text.isEmptyOrNull)
                        AnimatedContainer(
                          duration: Duration(milliseconds: 200),
                          height: 40,
                          margin: EdgeInsets.only(top: 8),
                          width: context.width(),
                          child: Row(
                            children: [
                              ColorSelectorBottomSheet(
                                list: textColors,
                                selectedColor: mStackedWidgetList.last.textColor,
                                onColorSelected: (c) {
                                  mStackedWidgetList.last.textColor = c;
                                  setState(() {});
                                },
                              ),
                            ],
                          ),
                        ),
                      if (mIsTextBgColor && !text.isEmptyOrNull)
                        AnimatedContainer(
                          duration: Duration(milliseconds: 200),
                          height: 40,
                          margin: EdgeInsets.only(top: 8),
                          alignment: Alignment.center,
                          width: context.width(),
                          child: Row(
                            children: [
                              ColorSelectorBottomSheet(
                                list: textColors,
                                selectedColor: mStackedWidgetList.last.backgroundColor,
                                onColorSelected: (c) {
                                  mStackedWidgetList.last.backgroundColor = c;
                                  setState(() {});
                                },
                              ),
                            ],
                          ),
                        ),
                      if (mIsTextSize && !text.isEmptyOrNull)
                        AnimatedContainer(
                          duration: Duration(milliseconds: 200),
                          margin: EdgeInsets.only(left: 16, top: 8, bottom: 8),
                          height: 30,
                          // color: Colors.grey.shade100,
                          width: context.width(),
                          child: Stack(
                            alignment: Alignment.centerLeft,
                            children: [
                              Slider(
                                value: mStackedWidgetList.last.size.validate(value: 16),
                                min: 10.0,
                                max: 100.0,
                                onChangeEnd: (v) {
                                  mStackedWidgetList.last.size = v;
                                  setState(() {});
                                },
                                onChanged: (v) {
                                  mStackedWidgetList.last.size = v;

                                  setState(() {});
                                },
                              ).paddingLeft(16),
                              Text('${mStackedWidgetList.last.size!.toInt()}' + '%'),
                            ],
                          ),
                        ),
                      if (mIsTextstyle && !text.isEmptyOrNull)
                        AnimatedContainer(
                          duration: Duration(milliseconds: 200),
                          height: 40,
                          alignment: Alignment.centerLeft,
                          margin: EdgeInsets.only(left: 16),
                          width: context.width(),
                          color: Colors.white,
                          child: Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            children: [
                              Container(
                                padding: EdgeInsets.all(6),
                                decoration:
                                    mStackedWidgetList.last.fontStyle == FontStyle.normal ? BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.black)) : null,
                                child: Text('Normal', style: boldTextStyle()).onTap(() {
                                  mStackedWidgetList.last.fontStyle = FontStyle.normal;
                                  mIsTextstyle = false;
                                  setState(() {});
                                }),
                              ),
                              Container(
                                padding: EdgeInsets.all(6),
                                decoration:
                                    mStackedWidgetList.last.fontStyle == FontStyle.italic ? BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.black)) : null,
                                child: Text('Italic', style: boldTextStyle(fontStyle: FontStyle.italic)).onTap(() {
                                  mStackedWidgetList.last.fontStyle = FontStyle.italic;
                                  mIsTextstyle = false;
                                  setState(() {});
                                }),
                              ),
                            ],
                          ),
                        ),
                      if (mIsBorderSliderVisible)
                        AnimatedContainer(
                          duration: Duration(milliseconds: 200),
                          height: mIsBorderSliderVisible ? 135 : 0,
                          // height: (outerBorderwidth != 0 || innerBorderwidth != 0) ? 130 : 96,
                          width: context.width(),
                          // color: Colors.grey.shade100,
                          child: Container(
                            color: Colors.white38,
                            child: Column(
                              children: [
                                6.height,
                                // 6.height.visible(outerBorderwidth != 0.0 && innerBorderwidth != 0.0),
                                30.height.visible(outerBorderwidth == 0.0 && innerBorderwidth == 0.0),
                                ColorSelectorBottomSheet(
                                  list: textColors,
                                  selectedColor: isOuterBorder ? outerBorderColor : innerBorderColor,
                                  onColorSelected: (c) {
                                    isOuterBorder ? outerBorderColor = c : innerBorderColor = c;
                                    setState(() {});
                                    appStore.addUndoList(
                                        undoModel: UndoModel(
                                            type: 'border', border: BorderModel(type: isOuterBorder ? 'outer' : 'inner', width: isOuterBorder ? outerBorderwidth : innerBorderwidth, borderColor: c)));
                                  },
                                ).visible(outerBorderwidth != 0 || innerBorderwidth != 0),
                                (outerBorderwidth != 0 || innerBorderwidth != 0) ? 6.height : 6.height,
                                Row(children: [
                                  8.width,
                                  InkWell(
                                      onTap: () => setState(() {
                                            isOuterBorder = true;
                                          }),
                                      child: Container(
                                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), color: isOuterBorder ? Colors.lightBlueAccent.withOpacity(0.5) : null),
                                          child: Text("Outer", style: primaryTextStyle()))),
                                  16.width,
                                  InkWell(
                                      onTap: () => setState(() {
                                            isOuterBorder = false;
                                          }),
                                      child: Container(
                                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), color: isOuterBorder == false ? Colors.lightBlueAccent.withOpacity(0.5) : null),
                                          child: Text("Inner", style: primaryTextStyle())))
                                ]),
                                Row(
                                  children: [
                                    8.width,
                                    Text('Border'),
                                    8.width,
                                    Slider(
                                      min: 0.0,
                                      max: 50,
                                      onChanged: (d) {
                                        isOuterBorder ? outerBorderwidth = d : innerBorderwidth = d;
                                        setState(() {});
                                      },
                                      value: isOuterBorder ? outerBorderwidth : innerBorderwidth,
                                      onChangeEnd: (d) {
                                        appStore.addUndoList(
                                            undoModel: UndoModel(
                                                type: 'border',
                                                border: BorderModel(type: isOuterBorder ? 'outer' : 'inner', width: d, borderColor: isOuterBorder ? outerBorderColor : innerBorderColor)));
                                        setState(() {});
                                        appStore.mStackedWidgetListundo1.forEach((element) {});
                                      },
                                    ).expand(),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (mIsContrastSliderVisible)
                        AnimatedContainer(
                          duration: Duration(milliseconds: 200),
                          height: mIsContrastSliderVisible ? 60 : 0,
                          width: context.width(),
                          // color: Colors.grey.shade100,
                          child: Container(
                            color: Colors.white38,
                            height: 60,
                            child: Row(
                              children: [
                                8.width,
                                Text('Contrast'),
                                8.width,
                                Slider(
                                  min: 0.0,
                                  max: 1.0,
                                  onChanged: (d) {
                                    contrast = d;
                                    setState(() {});
                                  },
                                  value: contrast,
                                  onChangeEnd: (d) {
                                    appStore.addUndoList(undoModel: UndoModel(type: 'contrast', number: d));
                                    setState(() {});
                                  },
                                ).expand(),
                              ],
                            ),
                          ),
                        ),
                      if (mIsSaturationSliderVisible)
                        AnimatedContainer(
                          duration: Duration(milliseconds: 200),
                          height: mIsSaturationSliderVisible ? 60 : 0,
                          width: context.width(),
                          // color: Colors.grey.shade100,
                          child: Container(
                            color: Colors.white38,
                            height: 60,
                            child: Row(
                              children: [
                                8.width,
                                Text('Saturation'),
                                8.width,
                                Slider(
                                  min: 0.0,
                                  max: 1.0,
                                  onChanged: (d) {
                                    saturation = d;
                                    setState(() {});
                                  },
                                  value: saturation,
                                  onChangeEnd: (d) {
                                    appStore.addUndoList(undoModel: UndoModel(type: 'saturation', number: d));
                                    setState(() {});
                                  },
                                ).expand(),
                              ],
                            ),
                          ),
                        ),
                      if (mIsHueSliderVisible)
                        AnimatedContainer(
                          duration: Duration(milliseconds: 200),
                          height: mIsHueSliderVisible ? 60 : 0,
                          width: context.width(),
                          // color: Colors.grey.shade100,
                          child: Container(
                            color: Colors.white38,
                            height: 60,
                            child: Row(
                              children: [
                                8.width,
                                Text('Hue'),
                                8.width,
                                Slider(
                                  min: 0.0,
                                  max: 1.0,
                                  onChanged: (d) {
                                    hue = d;
                                    setState(() {});
                                  },
                                  value: hue,
                                  onChangeEnd: (d) {
                                    appStore.addUndoList(undoModel: UndoModel(type: 'hue', number: d));
                                    setState(() {});
                                  },
                                ).expand(),
                              ],
                            ),
                          ),
                        ),
                      if (mIsFilterViewVisible)
                        AnimatedContainer(
                          duration: Duration(milliseconds: 200),
                          height: mIsFilterViewVisible ? 120 : 0,
                          width: context.width(),
                          child: FilterSelectionWidget(
                              isFreePhoto: widget.isFreePhoto,
                              image: croppedFile,
                              freeImage: croppedFileFree,
                              onSelect: (v) {
                                filter = v;
                                appStore.addUndoList(undoModel: UndoModel(type: 'filter', filter: v));
                                setState(() {});
                              }),
                        ),
                      if (mIsFrameVisible)
                        AnimatedContainer(
                          duration: Duration(milliseconds: 200),
                          height: mIsFrameVisible ? 120 : 0,
                          width: context.width(),
                          child: FrameSelectionWidget(onSelect: (v) {
                            frame = v;
                            if (v.isEmpty) frame = null;
                            appStore.addUndoList(undoModel: UndoModel(type: 'frame', data: v));
                            setState(() {});
                          }),
                        ),
                      if (mIsBlurVisible)
                        AnimatedContainer(
                          duration: Duration(milliseconds: 200),
                          height: mIsBlurVisible ? 120 : 0,
                          color: Colors.white38,
                          width: context.width(),
                          child: BlurSelectorBottomSheet(
                            sliderValue: blur,
                            onColorSelected: (v) {
                              blur = v;
                              setState(() {});
                            },
                            onColorSelectedEnd: (p0) {
                              appStore.addUndoList(undoModel: UndoModel(type: 'blur', number: p0));
                              setState(() {});
                            },
                          ),
                        ),
                      Container(
                        height: bottomWidgetHeight,
                        color: Colors.white12,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            ListView(
                              controller: scrollController,
                              scrollDirection: Axis.horizontal,
                              children: [
                                BottomBarItemWidget(title: 'Eraser', icons: Icon(FontAwesomeIcons.eraser).icon, onTap: () => onEraserClick()),
                                BottomBarItemWidget(title: 'Text', icons: Icon(Icons.text_fields_rounded).icon, onTap: () => onTextClick()),
                                BottomBarItemWidget(title: 'Neon', icons: Icon(Icons.text_fields_rounded).icon, onTap: () => onNeonLightClick()),
                                BottomBarItemWidget(title: 'Emoji', icons: Icon(FontAwesomeIcons.faceSmile).icon, onTap: () => onEmojiClick()),
                                BottomBarItemWidget(
                                    title: 'Stickers',
                                    icons: Icon(FontAwesomeIcons.faceSmileWink).icon,
                                    onTap: () {
                                      setState(() {
                                        onStickerClick();
                                      });
                                    }),
                                BottomBarItemWidget(
                                    title: 'Add Image',
                                    icons: Icon(Icons.image_outlined).icon,
                                    onTap: () {
                                      setState(() {
                                        onImageClick();
                                      });
                                    }),

                                /// Will be added in next update due to multiple finger bug
                                BottomBarItemWidget(title: 'Pen', icons: Icon(FontAwesomeIcons.penFancy).icon, onTap: () => onPenClick()),
                                BottomBarItemWidget(title: 'Brightness', icons: Icon(Icons.brightness_2_outlined).icon, onTap: () => onBrightnessSliderClick()),
                                BottomBarItemWidget(title: 'Contrast', icons: Icon(Icons.brightness_4_outlined).icon, onTap: () => onContrastSliderClick()),
                                BottomBarItemWidget(title: 'Saturation', icons: Icon(Icons.brightness_4_sharp).icon, onTap: () => onSaturationSliderClick()),
                                BottomBarItemWidget(title: 'Hue', icons: Icon(Icons.brightness_medium_sharp).icon, onTap: () => onHueSliderClick()),
                                BottomBarItemWidget(title: 'Blur', icons: Icon(MaterialCommunityIcons.blur).icon, onTap: () => onBlurClick()),
                                BottomBarItemWidget(title: 'Filter', icons: Icon(Icons.photo).icon, onTap: () => onFilterClick()),
                                // BottomBarItemWidget(title: 'Shape', icons: Icon(Icons.format_shapes_sharp).icon, onTap: () => onShapeClick()),
                                BottomBarItemWidget(title: 'Add Text Templet', icons: Icon(Icons.format_shapes_sharp).icon, onTap: () => onTextTemplet()),
                                BottomBarItemWidget(title: 'Border', icons: Icon(Icons.format_shapes_sharp).icon, onTap: () => onBorderSliderClick()),
                                BottomBarItemWidget(
                                    title: 'Frame', icons: !getBoolAsync(IS_FRAME_REWARDED) ? Icon(Icons.filter_frames).icon : Icon(Icons.lock_outline_rounded).icon, onTap: () => onFrameClick()),
                              ],
                            ).visible(mIsText == false && appStore.isText == false),
                            ListView(
                              controller: scrollController,
                              scrollDirection: Axis.horizontal,
                              children: [
                                8.width,
                                BottomBarItemWidget(
                                    title: 'Edit',
                                    icons: Icon(Icons.edit).icon,
                                    onTap: () async {
                                      text = await showInDialog(context,
                                          builder: (_) => TextEditorDialog(
                                                text: text.isEmptyOrNull ? "" : mStackedWidgetList.last.value,
                                              ));
                                      setState(() {
                                        mStackedWidgetList.last.value = text;
                                      });
                                    }),

                                BottomBarItemWidget(title: 'Font Family', icons: Icon(Icons.text_fields_rounded).icon, onTap: () => onTextStyle()),
                                8.width,
                                BottomBarItemWidget(
                                  title: 'Font Size',
                                  icons: Icon(Icons.font_download_outlined).icon,
                                  onTap: () => (setState(() {
                                    mIsTextSize = !mIsTextSize;
                                    mIsTextColor = false;
                                    mIsTextstyle = false;
                                    mIsTextBgColor = false;
                                  })),
                                ),
                                8.width,
                                BottomBarItemWidget(
                                  title: 'Bg Color',
                                  icons: Icon(Icons.color_lens_outlined).icon,
                                  onTap: () => (setState(() {
                                    mIsTextBgColor = !mIsTextBgColor;
                                    mIsTextColor = false;
                                    mIsTextstyle = false;
                                    mIsTextSize = false;
                                  })),
                                ),
                                8.width,
                                BottomBarItemWidget(
                                  title: 'Text Color',
                                  icons: Icon(Icons.format_color_fill).icon,
                                  onTap: () => (setState(() {
                                    mIsTextColor = !mIsTextColor;
                                    mIsTextstyle = false;
                                    mIsTextBgColor = false;
                                    mIsTextSize = false;
                                  })),
                                ),
                                // 8.width,
                                // BottomBarItemWidget(
                                //   title: 'Remove',
                                //   icons: Icon(Icons.delete_outline_outlined).icon,
                                //   onTap: () => (
                                //       setState(
                                //     () {
                                //       mIsTextColor = false;
                                //       mIsTextstyle = false;
                                //       mIsTextBgColor = false;
                                //       mIsTextSize = false;
                                //       appStore.removeUndoList();
                                //       appStore.mStackedWidgetListundo1.removeLast();
                                //       mIsText = false;
                                //       appStore.isText = false;
                                //       Navigator.pop(context);
                                //       // mStackedWidgetList.removeLast();
                                //       setState(() {});
                                //
                                //     },
                                //   )),
                                // ),
                              ],
                            ).visible(mIsText || appStore.isText),
                            // Positioned(
                            //   child: AnimatedCrossFade(
                            //       firstChild: Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey),
                            //       secondChild: Offstage(),
                            //       crossFadeState: mIsMoreConfigWidgetVisible ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                            //       duration: 700.milliseconds),
                            //   right: 8,
                            // ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ).paddingTop(context.statusBarHeight),
              Observer(builder: (_) => Loader().visible(appStore.isLoading)),
            ],
          ),
        ));
  }
}
