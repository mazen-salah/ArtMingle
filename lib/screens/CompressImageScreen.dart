import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../services/FileService.dart';
import '../../utils/Colors.dart';
import '../components/AppBarComponent.dart';
import '../main.dart';
import '../utils/AppPermissionHandler.dart';
import '../utils/Common.dart';
import 'DashboardScreen.dart';

class CompressImageScreen extends StatefulWidget {
  static String tag = '/CompressImageScreen';
  final File file;

  CompressImageScreen({required this.file});

  @override
  CompressImageScreenState createState() => CompressImageScreenState();
}

class CompressImageScreenState extends State<CompressImageScreen> {
  File? originalFile;
  File? compressedFile;

  int originalFileSize = 0;
  int compressFileSize = 0;

  bool isCompress = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    originalFile = widget.file;

    originalFileSize = originalFile!.lengthSync().toDouble() ~/ 1024.0;
  }

  Future<void> save(String path) async {
    checkPermission(context, func: () async {
      await ImageGallerySaver.saveFile(path, name: fileName(path));
      toast("Compressed image saved successfully");
      await 1.seconds.delay;
      DashboardScreen().launch(context, isNewTask: true);
    });
  }

  Future<void> compressFile() async {
    appStore.setLoading(true);

    compressedFile = await getCompressedFile(originalFile, await getFileSavePathWithName(), onDone: (aOriginalFileSize, aCompressFileSize) {
      appStore.setLoading(false);

      compressFileSize = aCompressFileSize;

      LiveStream().emit('refresh', true);
      isCompress = true;
      setState(() {});
    }).catchError((e) {
      // if (compressFileSize == 0) {
      //   toast("Your file is already compressed to ${compressFileSize},cant able to compress more");
      // }
      // print("Compress File Size ??" + compressFileSize.toString());

      appStore.setLoading(false);
      log(e.toString());
    });
    save(compressedFile!.path);
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    LiveStream().dispose('refresh');
    super.dispose();
  }

  // onDeviceBack() async {
  //   // finish(context, true);
  //   // return Future.value(false);
  //   return Future.value(true);
  //   // ;
  //   // onWillPop: () {
  //   //   finish(context, true);
  //   //   return Future.value(true);
  //   //   //
  //   // },
  // }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        finish(context, true);
        return Future.value(true);
        //
      },
      // PopScope(
      // canPop: true,
      // onPopInvoked: (bool didPop) async {
      //   onDeviceBack();
      // },
      child: Scaffold(
        appBar: appBarComponent(context: context, title: 'Compress Image'),
        body: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            ListView(
              padding: EdgeInsets.all(16),
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    8.height,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Text('Original File', style: boldTextStyle()),
                            8.height,
                            Image.file(originalFile!, height: (context.height() / 2) - 60, fit: BoxFit.cover),
                          ],
                        ).expand(),
                        16.width,
                        if (compressedFile != null)
                          Column(
                            children: [
                              Text('Compressed File', style: boldTextStyle(color: colorPrimary)),
                              8.height,
                              Image.file(compressedFile!, height: (context.height() / 2) - 60, fit: BoxFit.cover),
                            ],
                          ).expand(),
                      ],
                    ),
                    30.height,
                    Text("Original file size: $originalFileSize kb", style: primaryTextStyle()),
                    16.height,
                    compressedFile != null
                        ? RichText(
                            text: TextSpan(
                              text: 'Compress file size: ',
                              style: boldTextStyle(size: 18),
                              children: <TextSpan>[
                                TextSpan(text: compressFileSize.toString(), style: boldTextStyle(size: 18)),
                                TextSpan(text: ' kb', style: primaryTextStyle()),
                              ],
                            ),
                          )
                        : SizedBox(),
                    8.height,
                    compressedFile != null ? Text("You saved: ${originalFileSize - compressFileSize} kb", style: boldTextStyle(color: Color(0xFF00A508))) : SizedBox(),
                  ],
                ),
              ],
            ),
            AppButton(
              child: Text('Compress', style: boldTextStyle(color: Colors.white)),
              color: colorPrimary,
              width: context.width(),
              onTap: () {
                if (originalFileSize <= 2) {
                  toast("Unable to compress further, your file is already compressed to ${originalFileSize} kb.");
                } else {
                  compressFile();
                }
              },
            ).paddingAll(16).visible(!isCompress == true),
            Observer(builder: (_) => Loader().visible(appStore.isLoading)),
          ],
        ),
      ),
    );
  }
}
