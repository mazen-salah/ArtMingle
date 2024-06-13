import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../screens/PhotoEditScreen.dart';
import '../../screens/ViewAllFreePhotos.dart';
import '../../utils/Colors.dart';
import '../../utils/Common.dart';
import '../../utils/Images.dart';
import '../../components/AdsComponent.dart';
import '../utils/AdConfigurationConstants.dart';

class FreePhotosHorizontalListWidget extends StatefulWidget {
  @override
  FreePhotosHorizontalListWidgetState createState() => FreePhotosHorizontalListWidgetState();
}

class FreePhotosHorizontalListWidgetState extends State<FreePhotosHorizontalListWidget> with WidgetsBindingObserver {
  List<String> freePhotos = [
    wallpaper3,
    wallpaper11,
    wallpaper12,
    wallpaper13,
    wallpaper14,
  ];

  bool isInternetAvailable = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    init();
  }

  Future<void> init() async {
    checkInternet().then((internet) {
      // ignore: unnecessary_null_comparison
      if (internet != null && internet) {
        isInternetAvailable = true;
        setState(() {});

        if (!disableAdMob) {
          if (isAds == isGoogleAds) {
            loadInterstitialAd();
          } else {
            loadFaceBookInterstitialAd();
          }
        }
      } else {
        isInternetAvailable = false;
        setState(() {});
      }
      setState(() {});
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        onResumed();
        break;
      default:
    }
  }

  void onResumed() async {
    checkInternet().then((internet) {
      isInternetAvailable = internet;
      if (!internet) {
        setState(() {});
      }
      setState(() {});
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return isInternetAvailable
        ? Column(
            children: [
              16.height,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Free Photos', style: boldTextStyle(size: 18, letterSpacing: 0.5)),
                  Text('View All', style: secondaryTextStyle(size: 14)).onTap(() async {
                    if (!disableAdMob) {
                      if (isAds == isGoogleAds) {
                        showInterstitialAd(context);
                      }
                      if (isAds == isFacebookAds) {
                        showFacebookInterstitialAd();
                      }
                    }

                    // await 1.seconds.delay;
                    ViewAllFreePhotosScreen().launch(context);
                  }, splashColor: Colors.transparent, highlightColor: Colors.transparent),
                ],
              ).paddingSymmetric(horizontal: 16),
              Divider(color: viewLineColor, thickness: 2).paddingSymmetric(horizontal: 16),
              if (isInternetAvailable == true)
                HorizontalList(
                    itemCount: freePhotos.length,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemBuilder: (_, index) {
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: radius(12),
                          gradient: LinearGradient(colors: [itemGradient1.withOpacity(0.8), itemGradient2.withOpacity(0.8)], end: Alignment.topCenter, begin: Alignment.bottomCenter),
                        ),
                        child: cachedImage(freePhotos[index], width: context.width() / 3 - 16, height: 100, fit: BoxFit.cover).cornerRadiusWithClipRRect(12).onTap(() {
                          PhotoEditScreen(isFreePhoto: true, freeImage: freePhotos[index]).launch(context);
                        }),
                      );
                    }),
            ],
          )
        : SizedBox();
  }
}
