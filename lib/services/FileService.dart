import 'dart:io';
import 'dart:typed_data';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';

import 'package:image/image.dart' as Img;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../utils/Colors.dart';

DeviceInfoPlugin plugin = DeviceInfoPlugin();

Future<File> pickImage({ImageSource? imageSource}) async {
  XFile? pickedFile = await ImagePicker().pickImage(source: imageSource ?? ImageSource.gallery);

  if (pickedFile != null) {
    File file = File(pickedFile.path);

    return file;
  } else {
    throw errorSomethingWentWrong;
  }
}

Future<File> pickVideo({ImageSource? imageSource}) async {
  XFile? pickedFile = await ImagePicker().pickVideo(source: imageSource ?? ImageSource.gallery);

  if (pickedFile != null) {
    File file = File(pickedFile.path);

    return file;
  } else {
    throw errorSomethingWentWrong;
  }
}

Future<List<File>> pickMultipleImage({double? maxWidth, double? maxHeight, int? quality}) async {
  List<XFile>? pickedFile = await ImagePicker().pickMultiImage(maxWidth: maxWidth, maxHeight: maxHeight, imageQuality: quality);

  if (pickedFile.isNotEmpty) {
    List<File> file = [];
    pickedFile.forEach((element) {
      file.add(File(element.path));
    });

    return file;
  } else {
    throw errorSomethingWentWrong;
  }
}

Future<String> getFileSavePathWithName() async {
  Directory dir = await getFileSaveDirectory();

  String fileName = '${dir.path}/${currentTimeStamp().toString()}.jpg';

  return fileName;
}

Future<String> getFileSavePath() async {
  Directory dir = await getFileSaveDirectory();
  return dir.path;
}

Future<Directory> getFileSaveDirectory() async {
  return await getApplicationSupportDirectory();
}

Future<List<FileSystemEntity>> getLocalSavedImageDirectories() async {
  Directory dir = await getFileSaveDirectory();

  return dir.listSync().where((element) => element.path.isImage).toList();
}

Future<File> saveToDirectory(File? file, {bool isFullPath = false}) async {
  AndroidDeviceInfo android = await plugin.androidInfo;

  var status = android.version.sdkInt < 33 ? await Permission.storage.request() : await Permission.photos.request();

  if (status.isGranted) {
    String path = '';
    if (isFullPath) {
      path = await getFileSavePath();
    } else {
      path = await getFileSavePathWithName();
    }

    File saveFile = File(path)..createSync();

    file!.copySync(path);
    file.deleteSync();

    log(path);

    log('Save to ${saveFile.path}');

    LiveStream().emit('refresh', true);
    return saveFile;
  } else {
    throw errorSomethingWentWrong;
  }
}

Future<File> getCompressedFile(File? file, String targetPath, {Function(int, int)? onDone}) async {
  AndroidDeviceInfo android = await plugin.androidInfo;

  var status = android.version.sdkInt < 33 ? await Permission.storage.request() : await Permission.photos.request();
  if (status.isGranted) {
    return await FlutterNativeImage.compressImage(file!.path, quality: 70).then((File? v) async {
      if (v != null) {
        log(file.lengthSync());
        double originalFile = file.lengthSync().toDouble() / 1024.0;

        File result = await saveToDirectory(v);

        log(result.existsSync());
        log(result.lengthSync());
        double compressFile = result.lengthSync().toDouble() / 1024.0;

        onDone?.call(originalFile.toInt(), compressFile.toInt());

        toast("Compress image successfully.Save file in folder");

        return result;
      } else {
        throw errorSomethingWentWrong;
      }
    }).catchError((e) {
      log(e);
      throw e;
    });
  } else {
    throw 'Permission not granted';
  }
}

Future<File?> getResizeFile(BuildContext context, File? file, double sliderValue, {Function(int?, int?, int, int)? onDone}) async {
  AndroidDeviceInfo android = await plugin.androidInfo;

  var status = android.version.sdkInt < 33 ? await Permission.storage.request() : await Permission.photos.request();

  File? saved;
  if (status.isGranted) {
    double fileOriginalKb = file!.lengthSync().toDouble() / 1024.0;
    print("FILES" + file.path.toString());
    if (sliderValue == 100) sliderValue = 99;

    File compressedFile = await FlutterNativeImage.compressImage(file.path, quality: 70, percentage: 100 - sliderValue.toInt());

    saved = await saveToDirectory(compressedFile);
    double resizeKb = saved.lengthSync().toDouble() / 1024.0;
    // print("FILES" + saved.path.toString());

    ImageProperties resizedProperties = await FlutterNativeImage.getImageProperties(saved.path);

    onDone?.call(resizedProperties.height, resizedProperties.width, resizeKb.toInt(), fileOriginalKb.toInt());
  }
  return saved;
}

Future<void> cropImage({bool isFreePhoto = false, String? networkImage, File? imageFile, Function(File)? onDone}) async {
  if (!isFreePhoto) {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile!.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: colorPrimary,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
          activeControlsWidgetColor: colorPrimary,
        ),
        IOSUiSettings(
          title: 'Crop Image',
        ),
      ],
      aspectRatioPresets: Platform.isAndroid
          ? [
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9,
            ]
          : [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio5x3,
              CropAspectRatioPreset.ratio5x4,
              CropAspectRatioPreset.ratio7x5,
              CropAspectRatioPreset.ratio16x9
            ],
    );
    if (croppedFile != null) {
      print(croppedFile);
      onDone?.call(File(croppedFile.path));
    }
  }
}

/// Not working as Expected
Future<Uint8List> removeWhiteBackground(Uint8List bytes) async {
  AndroidDeviceInfo android = await plugin.androidInfo;
  var status = android.version.sdkInt < 33 ? await Permission.storage.request() : await Permission.photos.request();
  if (status.isGranted) {
    Img.Image image = Img.decodeImage(bytes)!;
    Img.Image transparentImage = await colorTransparent(image, 255, 255, 255);
    List<int> newPng = Img.encodePng(transparentImage);
    return Uint8List.fromList(newPng);
  } else {
    throw 'Permission not granted';
  }
}

Future<Img.Image> colorTransparent(Img.Image src, int red, int green, int blue) async {
  var pixels = src.getBytes();
  for (int i = 0, len = pixels.length; i < len; i += 4) {
    if (pixels[i] == red && pixels[i + 1] == green && pixels[i + 2] == blue) {
      pixels[i + 3] = 0;
    }
  }
  return src;
}
