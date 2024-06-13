import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../utils/AdConfigurationConstants.dart';

extension IntExt on int {
  Size get size => Size(this.toDouble(), this.toDouble());
}

String get getBannerAdId => mAdMobBannerId;

String get getInterstitialId => mAdMobInterstitialId;

String get getNativeAdvancedId => mAdMobNativeAdvancedId;

String get getRewardedId => mAdMobRewardedId;

Future<bool> checkInternet() async {
  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult == ConnectivityResult.mobile) {
    return true;
  } else if (connectivityResult == ConnectivityResult.wifi) {
    return true;
  }
  return false;
}

fileName(String path) {
  File file = new File(path);
  String fileName = file.path.split('/').last.splitBefore(".");
  return fileName;
}

Widget cachedImage(String? url, {double? height, double? width, BoxFit? fit, Key? key, AlignmentGeometry? alignment, bool usePlaceholderIfUrlEmpty = true, double? radius}) {
  if (url.validate().isEmpty) {
    return placeHolderWidget(height: height, width: width, fit: fit, alignment: alignment, radius: radius);
  } else if (url.validate().startsWith('http')) {
    return Image.network(
      url!,
      height: height,
      width: width,
      fit: fit,
      key: key,
      errorBuilder: (BuildContext? context, Object? exception, StackTrace? stackTrace) {
        return Image.asset('assets/placeholder.jpg', height: height, width: width, fit: fit, alignment: alignment ?? Alignment.center).cornerRadiusWithClipRRect(radius ?? defaultRadius);
      },
      alignment: alignment as Alignment? ?? Alignment.center,
    );
  } else {
    return Image.asset('assets/placeholder.jpg', height: height, width: width, fit: fit, alignment: alignment ?? Alignment.center).cornerRadiusWithClipRRect(radius ?? defaultRadius);
  }
}

Widget placeHolderWidget({double? height, double? width, BoxFit? fit, AlignmentGeometry? alignment, double? radius}) {
  return Image.asset('assets/placeholder.jpg', height: height, width: width, fit: fit ?? BoxFit.cover, alignment: alignment ?? Alignment.center).cornerRadiusWithClipRRect(radius ?? defaultRadius);
}
