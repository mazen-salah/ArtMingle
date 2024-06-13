import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../utils/Colors.dart';
import '../models/UndoModel.dart';

part 'AppStore.g.dart';

class AppStore = _AppStore with _$AppStore;

abstract class _AppStore with Store {
  @observable
  bool isDarkMode = false;

  @observable
  bool isLoading = false;

  @observable
  bool isText = false;

  @observable
  ObservableList<File> collegeMakerImageList = ObservableList.of(<File>[]);

  @observable
  List<UndoModel> mStackedWidgetListundo = [];

  @observable
  List<UndoModel> mStackedWidgetListundo1 = [];

  @action
  void addUndoList({UndoModel? undoModel}){
    mStackedWidgetListundo1.add(undoModel!);
  }

  @action
  void removeUndoList(){
    mStackedWidgetListundo1.removeLast();
  }
  @action
  void addRedoList({UndoModel? undoModel}){
    mStackedWidgetListundo.add(undoModel!);
  }

  @action
  void removeRedoList(){
    mStackedWidgetListundo.removeLast();
  }

  @action
  void addCollegeImages(File image) {
    collegeMakerImageList.add(image);
  }

  @action
  void clearCollegeImageList() {
    collegeMakerImageList.clear();
  }

  @action
  void setLoading(bool val) {
    isLoading = val;
  }

  @action
  Future<void> setDarkMode(bool aIsDarkMode) async {
    isDarkMode = aIsDarkMode;

    if (isDarkMode) {
      textPrimaryColorGlobal = Colors.white;
      textSecondaryColorGlobal = textSecondaryColor;

      defaultLoaderBgColorGlobal = scaffoldSecondaryDark;
      shadowColorGlobal = Colors.white12;
    } else {
      textPrimaryColorGlobal = textPrimaryColor;
      textSecondaryColorGlobal = textSecondaryColor;

      defaultLoaderBgColorGlobal = Colors.white;
      shadowColorGlobal = Colors.black12;
    }
  }
}
