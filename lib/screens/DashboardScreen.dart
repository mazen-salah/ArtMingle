import 'package:facebook_audience_network/ad/ad_banner.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nb_utils/nb_utils.dart';
import '/../utils/AppPermissionHandler.dart';
import '../../components/AdsComponent.dart';
import '../../components/FreePhotosHorizontalListWidget.dart';
import '../../components/HomeItemListWidget.dart';
import '../../components/LastEditedListWidget.dart';
import '../../main.dart';
import '../../utils/AdConfigurationConstants.dart';
import '../../utils/Colors.dart';
import '../services/FileService.dart';
import '../utils/Common.dart';

class DashboardScreen extends StatefulWidget {
  static String tag = '/HomeScreen';

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  BannerAd? myBanner;
  bool isEmpty = true;
  bool isInternetAvailable = false;

  DateTime? currentBackPressTime;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    if (getBoolAsync("isFirst", defaultValue: true)) {
      checkPermission(context, isShowSubtitle: false);
      setValue("isFirst", false);
    }
    if (!disableAdMob && isAds == isGoogleAds) {
      myBanner = buildBannerAd()..load();
    }
    if (!disableAdMob && isAds == isFacebookAds) {
      loadFaceBookInterstitialAd();
    }
    checkInternet().then((value) {
      isInternetAvailable = value;
      if (!value) {
        isEmpty = true;
        setState(() {});
      }
      setState(() {});
    });

    setState(() {});
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
    LiveStream().dispose('refresh');
    super.dispose();
  }

  // onDeviceBack() async {
  //   DateTime now = DateTime.now();
  //   if (currentBackPressTime == null || now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
  //     currentBackPressTime = now;
  //     toast('Press back again to exit');
  //     return Future.value(false);
  //   }
  //   return Future.value(true);
  //   // },
  //   // finish(context, true);
  //   // // return Future.value(false);
  //   // return true;
  //   // onWillPop: () {
  //   //   finish(context, true);
  //   //   return Future.value(true);
  //   //   //
  //   // },
  // }

  @override
  Widget build(BuildContext context) {
    getLocalSavedImageDirectories().then((value) {
      if (value.isNotEmpty && isInternetAvailable == true) {
        isEmpty = false;
        setState(() {});
      }
    });
    return WillPopScope(
      onWillPop: () async {
        DateTime now = DateTime.now();
        if (currentBackPressTime == null || now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
          currentBackPressTime = now;
          toast('Press back again to exit');
          return Future.value(false);
        }
        return Future.value(true);
      },
      child: Scaffold(
        body: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              height: context.height(),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [itemGradient1, itemGradient2], end: Alignment.centerLeft, begin: Alignment.centerRight),
              ),
              child: CustomScrollView(
                physics: AlwaysScrollableScrollPhysics(parent: RangeMaintainingScrollPhysics()),
                slivers: [
                  SliverAppBar(
                    backgroundColor: Colors.transparent,
                    expandedHeight: 150,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Let\'s Make Your ', style: primaryTextStyle(size: 28, color: Colors.white)),
                          Text('Photo Better !', style: primaryTextStyle(size: 28, color: Colors.white)),
                          8.height,
                        ],
                      ).paddingAll(16),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        Container(
                          height: isEmpty == true ? context.height() - 196 : null,
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24))),
                          child: SingleChildScrollView(
                            padding: EdgeInsets.only(bottom: AdSize.banner.height.toDouble()),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                16.height,
                                HomeItemListWidget(
                                  onUpdate: () {
                                    setState(() {});
                                  },
                                ),
                                FreePhotosHorizontalListWidget(),
                                16.height,
                                LastEditedListWidget(
                                  isDashboard: true,
                                  onUpdate: () {
                                    setState(() {
                                      getLocalSavedImageDirectories().then((value) {
                                        if (value.isNotEmpty) {
                                          isEmpty = false;
                                        } else {
                                          isEmpty = true;
                                          setState(() {});
                                        }
                                      });
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
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
      ),
    );
  }
}
