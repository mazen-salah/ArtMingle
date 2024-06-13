import 'package:facebook_audience_network/ad/ad_banner.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../components/AdsComponent.dart';
import '../../main.dart';
import '../../screens/NoInternetScreen.dart';
import '../../screens/PhotoEditScreen.dart';
import '../../utils/AdConfigurationConstants.dart';
import '../../utils/Colors.dart';
import '../../utils/Common.dart';
import '../../utils/Images.dart';
import '../components/AppBarComponent.dart';

class ViewAllFreePhotosScreen extends StatefulWidget {
  @override
  ViewAllFreePhotosScreenState createState() => ViewAllFreePhotosScreenState();
}

class ViewAllFreePhotosScreenState extends State<ViewAllFreePhotosScreen> {
  BannerAd? myBanner;
  List<String> freePhotos = [
    wallpaper3,
    wallpaper11,
    wallpaper12,
    wallpaper13,
    wallpaper14,
    wallpaper23,
    wallpaper24,
    wallpaper25,
    wallpaper26,
    wallpaper27,
    wallpaper28,
    wallpaper29,
    wallpaper30,
    wallpaper31,
    wallpaper32,
    wallpaper33,
    wallpaper15,
    wallpaper16,
    wallpaper17,
    wallpaper18,
    wallpaper19,
    wallpaper20,
    wallpaper21,
    wallpaper22,
  ];

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    checkInternet().then((internet) {
      // ignore: unnecessary_null_comparison
      if (internet != null && internet) {
        loadFaceBookInterstitialAd();
        if (!disableAdMob && isAds == isGoogleAds) {
          myBanner = buildBannerAd()..load();
        }
      } else {
        NoInternetScreen().launch(context);
      }
    });
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:appBarComponent(context: context,title:'Free Photos' ),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            // padding: EdgeInsets.only(bottom: 100),
            height: context.height(),
            child: SingleChildScrollView(
              child: SafeArea(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  runAlignment: WrapAlignment.start,
                  children: freePhotos.map((data) {
                    return Container(
                      // padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        borderRadius: radius(12),
                        gradient: LinearGradient(colors: [
                          itemGradient1.withOpacity(0.8),
                          itemGradient2.withOpacity(0.8),
                        ], end: Alignment.topCenter, begin: Alignment.bottomCenter),
                      ),
                      child: cachedImage(data, width: context.width() / 3 - 16, height: 100, fit: BoxFit.cover).cornerRadiusWithClipRRect(12).onTap(() {
                        PhotoEditScreen(isFreePhoto: true, freeImage: data).launch(context);
                      }),
                    );
                  }).toList(),
                ).paddingOnly(right: 16, left: 16, bottom: 100, top: 16),
              ),
            ),
          ),
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
    );
  }
}
