import 'package:facebook_audience_network/ad/ad_interstitial.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../main.dart';
import '../../utils/AdConfigurationConstants.dart';
import 'package:nb_utils/nb_utils.dart';

bool isInterstitialAdLoaded = false;
bool isRewardedAdLoaded = false;
bool isRewardedAdLoadAds = false;

Widget currentAd = SizedBox(width: 0.0, height: 0.0);

void loadFaceBookInterstitialAd() {
  FacebookInterstitialAd.loadInterstitialAd(
    placementId: faceBookInterstitialPlacementId,
    listener: (result, value) {
      print(">> FAN > Interstitial Ad: $result --> $value");
      if (result == InterstitialAdResult.LOADED) {
        print(result.toString());
        isInterstitialAdLoaded = true;
      }
      if (result == InterstitialAdResult.DISMISSED && value["invalidated"] == true) {
        print(result.toString());
        isInterstitialAdLoaded = false;
      }
    },
  );
}

showFacebookInterstitialAd() {
  if (isInterstitialAdLoaded == true)
    FacebookInterstitialAd.showInterstitialAd();
  else
    print("Facebook Interstial Ad not yet loaded!");
}

void loadInterstitialAd() {
  InterstitialAd.load(
    adUnitId: mAdMobInterstitialId,
    request: AdRequest(),
    adLoadCallback: InterstitialAdLoadCallback(
      onAdLoaded: (InterstitialAd ad) {
        log('${ad.runtimeType} loaded.');
        interstitialReady = true;
        myInterstitial = ad;
      },
      onAdFailedToLoad: (LoadAdError error) {
        log('InterstitialAd failed to load: $error.');
        myInterstitial = null;
      },
    ),
  );
}

void showInterstitialAd(BuildContext context, {bool aIsFinish = true}) {
  if (myInterstitial == null) {
    log('attempt to show interstitial before loaded.');
    if (aIsFinish) {
      finish(context);
    }
    return;
  }
  myInterstitial!.fullScreenContentCallback = FullScreenContentCallback(
    onAdShowedFullScreenContent: (InterstitialAd ad) => print('ad onAdShowedFullScreenContent.'),

    onAdDismissedFullScreenContent: (InterstitialAd ad) {
      log('$ad onAdDismissedFullScreenContent.');
      loadInterstitialAd();
      myInterstitial!.dispose();
    },
    onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
      log('$ad onAdFailedToShowFullScreenContent: $error');
      loadInterstitialAd();
      myInterstitial!.dispose();
    },
  );
  myInterstitial!.show();
}
