import 'dart:io';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../components/AdsComponent.dart';
import '../../screens/LastEditedPictureScreen.dart';
import '../../services/FileService.dart';
import '../../utils/AdConfigurationConstants.dart';
import 'PhotoViewerWidget.dart';

class LastEditedListWidget extends StatefulWidget {
  final bool isDashboard;
  final Function()? onUpdate;

  LastEditedListWidget({this.isDashboard = false, this.onUpdate});

  @override
  LastEditedListWidgetState createState() => LastEditedListWidgetState();
}

class LastEditedListWidgetState extends State<LastEditedListWidget> {
  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    LiveStream().on('refresh', (v) {
      setState(() {});
    });

    if (!disableAdMob) {
      if (isAds == isGoogleAds) {
        loadInterstitialAd();
      } else {
        loadFaceBookInterstitialAd();
      }
    }
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

  @override
  Widget build(BuildContext context) {
    return Container(
      // padding: EdgeInsets.all(8),
      margin: EdgeInsets.only(left: 16, right: 16),
      width: isWeb ? 500 : context.width(),
      child: FutureBuilder<List<FileSystemEntity>>(
        future: getLocalSavedImageDirectories(),
        builder: (_, snap) {
          if (snap.hasData) {
            int counter = widget.isDashboard
                ? snap.data!.length < 6
                    ? snap.data!.length
                    : 6
                : snap.data!.length;
            if (snap.data!.isEmpty) return SizedBox(height: 0);

            return snap.data!.isEmpty
                ? Text('no data').center()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Last saved pictures', style: boldTextStyle(size: 18, letterSpacing: 0.3, wordSpacing: 0.5)),
                          Text('View All', style: secondaryTextStyle(size: 14)).onTap(
                            () async {
                              if (!disableAdMob) {
                                if (isAds == isGoogleAds) {
                                  showInterstitialAd(context);
                                }
                                if (isAds == isFacebookAds) {
                                  showFacebookInterstitialAd();
                                }
                              }
                              bool res = await LastEditedPictureScreen().launch(context, pageRouteAnimation: PageRouteAnimation.Fade, duration: 300.milliseconds);
                              log(res);
                              if (res == true) {
                                setState(() {});
                                widget.onUpdate!.call();
                              }
                            },
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                          )
                        ],
                      ).visible(widget.isDashboard),
                      Divider(color: viewLineColor, thickness: 2).visible(widget.isDashboard),
                      8.height,
                      SingleChildScrollView(
                        padding: EdgeInsets.only(bottom: widget.isDashboard ? 0 : 50),
                        physics: NeverScrollableScrollPhysics(),
                        // physics: widget.isDashboard ? NeverScrollableScrollPhysics() : AlwaysScrollableScrollPhysics(),
                        child: Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: snap.data!.reversed.take(counter).map((data) {
                            // log(data);
                            if (data.path.isImage) {
                              return Image.file(File(data.path), width: context.width() / 3 - 22, height: 170, fit: BoxFit.cover).cornerRadiusWithClipRRect(12).onTap(() {
                                PhotoViewerWidget(data).launch(context).then((value) {
                                  setState(() {});
                                  widget.onUpdate!.call();
                                });
                              });
                            } else {
                              return SizedBox();
                            }
                          }).toList(),
                        ),
                      ),
                    ],
                  );
          } else {
            return widget.isDashboard ? SizedBox() : SizedBox(height: 500, child: Text('no data'));
          }
        },
      ),
    );
  }
}
