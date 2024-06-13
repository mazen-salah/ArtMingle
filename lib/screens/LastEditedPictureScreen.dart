import 'package:facebook_audience_network/ad/ad_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../components/AdsComponent.dart';
import '../../components/LastEditedListWidget.dart';
import '../../services/FileService.dart';
import '../../utils/AdConfigurationConstants.dart';
import '../../utils/Colors.dart';

import '../main.dart';

class LastEditedPictureScreen extends StatefulWidget {
  @override
  LastEditedPictureScreenState createState() => LastEditedPictureScreenState();
}

class LastEditedPictureScreenState extends State<LastEditedPictureScreen> {
  BannerAd? myBanner;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    if (!disableAdMob && isAds == isGoogleAds) {
      myBanner = buildBannerAd()..load();
    }
    if (!disableAdMob && isAds == isFacebookAds) {
      loadFaceBookInterstitialAd();
      loadFaceBookInterstitialAd();
    }
  }

  BannerAd buildBannerAd() {
    return BannerAd(
      size: AdSize.banner,
      request: AdRequest(),
      adUnitId: mAdMobBannerId,
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          log('${ad.runtimeType} loaded.');
          myBanner = ad as BannerAd;
          myBanner!.load();
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          log('${ad.runtimeType} failed to load: $error.');
          ad.dispose();
          bannerReady = true;
        },
        onAdOpened: (Ad ad) {
          log('${ad.runtimeType} onAdOpened.');
        },
        onAdClosed: (Ad ad) {
          log('${ad.runtimeType} closed.');
          ad.dispose();
        },
      ),
    );
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    myBanner?.dispose();
    super.dispose();
  }

  onDeviceBack() async {
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          finish(context, true);
          return Future.value(true);
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text('Last saved pictures', style: boldTextStyle(color: Colors.white, size: 20, letterSpacing: 0.3, wordSpacing: 0.5)),
            foregroundColor: Colors.white,
            leading: Icon(Icons.arrow_back, color: Colors.white, size: 24).onTap(() {
              finish(context, true);
            }),
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [itemGradient1, itemGradient2], end: Alignment.centerLeft, begin: Alignment.centerRight),
              ),
            ),
            actions: [
              IconButton(
                padding: EdgeInsets.zero,
                icon: Icon(Feather.trash, size: 20),
                onPressed: () {
                  showConfirmDialogCustom(context, dialogType: DialogType.CONFIRMATION, primaryColor: colorPrimary, title: 'Do you want to delete all saved pictures?', onAccept: (context) {
                    getFileSaveDirectory().then((value) async {
                      value.deleteSync(recursive: true);
                      setState(() {});

                      await 500.milliseconds.delay;
                      if (!disableAdMob && isAds == isGoogleAds) {
                        showInterstitialAd(context, aIsFinish: false);
                      }
                      if (!disableAdMob && isAds == isFacebookAds) {
                        showFacebookInterstitialAd();
                      }
                    });
                  });
                },
              ),
            ],
          ),
          body: SafeArea(
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                SingleChildScrollView(padding: EdgeInsets.only(bottom: 50), child: LastEditedListWidget(isDashboard: false)),
                if (isAds == isGoogleAds && myBanner != null)
                  Positioned(
                    child: Container(child: myBanner != null ? AdWidget(ad: myBanner!) : SizedBox(), color: Color(0xFFEEF6FD)),
                    bottom: 0,
                    height: AdSize.banner.height.toDouble(),
                    width: context.width(),
                  ),
                if (isAds == isFacebookAds)
                  FacebookBannerAd(
                    placementId: faceBookBannerPlacementId,
                    bannerSize: BannerSize.STANDARD,
                    listener: (result, value) {
                      print("Banner Ad: $result -->  $value");
                    },
                  ),
              ],
            ),
          ),
        ));
  }
}
