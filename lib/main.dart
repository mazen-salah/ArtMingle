import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../AppTheme.dart';
import '../../screens/SplashScreen.dart';
import '../../store/AppStore.dart';
import '../../utils/Constants.dart';

AppStore appStore = AppStore();

bool bannerReady = false;
bool interstitialReady = false;
bool isRewardedAdReady = false;
bool rewarded = false;

InterstitialAd? myInterstitial;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  defaultSpreadRadius = 0.5;
  defaultBlurRadius = 3.0;
  appButtonBackgroundColorGlobal = Colors.white;

  await initialize();

  await Firebase.initializeApp().then((value) {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
    MobileAds.instance.initialize();
  });

  RequestConfiguration configuration = RequestConfiguration(testDeviceIds: ['E46609DD331AF2754D38B3DCE3ED011B']);
  MobileAds.instance.updateRequestConfiguration(configuration);

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: mAppName,
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: SplashScreen(),
      scrollBehavior: MyBehavior(),
    );
  }
}

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
