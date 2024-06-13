import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:share/share.dart';
import '../../utils/Colors.dart';
import 'package:video_trimmer/video_trimmer.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

import '../utils/AppPermissionHandler.dart';
import '../utils/Common.dart';

class TrimVideoScreen extends StatefulWidget {
  static String tag = '/TrimVideoScreen';
  final File file;

  TrimVideoScreen({required this.file});

  @override
  _TrimVideoScreenState createState() => _TrimVideoScreenState();
}

class _TrimVideoScreenState extends State<TrimVideoScreen> {
  File? originalFile;
  File? trimmedFile;
  final Trimmer trimmer = Trimmer();

  double startValue = 0.0;
  double endValue = 0.0;

  bool isPlaying = false;
  bool progressVisibility = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    originalFile = widget.file;

    await trimmer.loadVideo(videoFile: widget.file);

    setState(() {});
  }

  Future<void> saveVideo(int val) async {
    setState(() {
      progressVisibility = true;
    });

    trimmer.saveTrimmedVideo(
      startValue: startValue,
      endValue: endValue,
      onSave: (path) async {
        setState(() {
          progressVisibility = false;
        });
        if (val == 0) {
          share(path!);
        }
        if (val == 1) {
          save(path!);
        }
      },
    );
  }

  Future<void> save(String path) async {
    log('Path: $path');
    checkPermission(context, func: () async {
      await ImageGallerySaver.saveFile(path, name: fileName(path));
      toast("Trimmed video saved successfully");
      await 1.seconds.delay;
      finish(context);
    }, name: "video");
  }

  Future<void> share(String path) async {
    Share.share(path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        'Trim Video',
        backWidget: CloseButton(
          onPressed: () {
            showConfirmDialogCustom(context, title: 'You trim video will be lost', primaryColor: colorPrimary, positiveText: 'Ok', negativeText: 'Cancel', onAccept: (context) {
              finish(context);
            });
          },
        ),
        actions: [
          IconButton(
            onPressed: () => saveVideo(0),
            icon: Icon(MaterialCommunityIcons.share),
          ),
          TextButton(
            onPressed: () => saveVideo(1),
            child: Text('Save', style: boldTextStyle(color: colorPrimary, size: 18)).withShaderMaskGradient(LinearGradient(colors: [itemGradient1, itemGradient2])),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          LinearProgressIndicator(
            backgroundColor: itemGradient2,
            valueColor: AlwaysStoppedAnimation<Color>(itemGradient1),
          ).visible(progressVisibility),
          8.height,
          Stack(
            alignment: Alignment.center,
            children: [
              VideoViewer(trimmer: trimmer),
              Align(
                alignment: Alignment.center,
                child: TextButton(
                  child: isPlaying
                      ? Icon(
                          Icons.pause,
                          size: 60.0,
                        ).withShaderMaskGradient(LinearGradient(colors: [itemGradient1, itemGradient2]))
                      : Icon(
                          Icons.play_arrow,
                          size: 60.0,
                        ).withShaderMaskGradient(LinearGradient(colors: [itemGradient1, itemGradient2])),
                  onPressed: () async {
                    bool playbackState = await trimmer.videoPlaybackControl(
                      startValue: startValue,
                      endValue: endValue,
                    );
                    setState(() {
                      isPlaying = playbackState;
                    });
                  },
                ),
              ),
            ],
          ).expand(),
          8.height,
          TrimViewer(
            showDuration: true,
            durationTextStyle: primaryTextStyle(color: Colors.grey),
            trimmer: trimmer,
            viewerHeight: 50.0,
            viewerWidth: context.width() - 8,
            maxVideoLength: Duration(hours: 1),
            editorProperties: TrimEditorProperties(borderPaintColor: colorPrimary, circlePaintColor: colorPrimary),
            onChangeStart: (value) {
              startValue = value;
            },
            onChangeEnd: (value) {
              endValue = value;
            },
            onChangePlaybackState: (value) {
              setState(() {
                isPlaying = value;
              });
            },
          ).paddingOnly(bottom: 16),
        ],
      ),
    );
  }
}
