import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:permission_handler/permission_handler.dart';
import '/../utils/Colors.dart';

Future<void> checkPermission(BuildContext context, {Function()? func, isShowSubtitle = true, String name = "image"}) async {
  DeviceInfoPlugin plugin = DeviceInfoPlugin();
  AndroidDeviceInfo android = await plugin.androidInfo;
  var status = android.version.sdkInt < 33 ? await Permission.storage.request() : await Permission.photos.request();

  if (status == PermissionStatus.denied || !status.isGranted) {
    // if the user denied (it's the case if user deny two times)
    bool? isConfirm = false;
    await showConfirmDialogCustom(
      context,
      title: 'Allow app to access your storage ?',
      subTitle: isShowSubtitle ? "You need to allow storage permission to save $name in gallery" : "",
      positiveText: 'Allow',
      negativeText: 'Don\'t allow',
      primaryColor: colorPrimary,
      onAccept: (context) {
        isConfirm = true;
      },
    );
    if (isConfirm ?? true) {
      if (!await Permission.storage.status.isGranted) {
        await android.version.sdkInt < 33 ? await Permission.storage.request() : await Permission.photos.request();
      }
      if (await Permission.storage.status.isDenied) {
        openAppSettings();
        // Navigator.pop(context);
      } else {
        status = await Permission.storage.status;
      }
    }
  }

  if (status.isGranted) {
    func!.call();
  }
}
