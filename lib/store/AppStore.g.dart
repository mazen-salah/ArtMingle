// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'AppStore.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$AppStore on _AppStore, Store {
  late final _$isDarkModeAtom =
      Atom(name: '_AppStore.isDarkMode', context: context);

  @override
  bool get isDarkMode {
    _$isDarkModeAtom.reportRead();
    return super.isDarkMode;
  }

  @override
  set isDarkMode(bool value) {
    _$isDarkModeAtom.reportWrite(value, super.isDarkMode, () {
      super.isDarkMode = value;
    });
  }

  late final _$isLoadingAtom =
      Atom(name: '_AppStore.isLoading', context: context);

  @override
  bool get isLoading {
    _$isLoadingAtom.reportRead();
    return super.isLoading;
  }

  @override
  set isLoading(bool value) {
    _$isLoadingAtom.reportWrite(value, super.isLoading, () {
      super.isLoading = value;
    });
  }

  late final _$collegeMakerImageListAtom =
      Atom(name: '_AppStore.collegeMakerImageList', context: context);

  @override
  ObservableList<File> get collegeMakerImageList {
    _$collegeMakerImageListAtom.reportRead();
    return super.collegeMakerImageList;
  }

  @override
  set collegeMakerImageList(ObservableList<File> value) {
    _$collegeMakerImageListAtom.reportWrite(value, super.collegeMakerImageList,
        () {
      super.collegeMakerImageList = value;
    });
  }

  late final _$mStackedWidgetListundoAtom =
      Atom(name: '_AppStore.mStackedWidgetListundo', context: context);

  @override
  List<UndoModel> get mStackedWidgetListundo {
    _$mStackedWidgetListundoAtom.reportRead();
    return super.mStackedWidgetListundo;
  }

  @override
  set mStackedWidgetListundo(List<UndoModel> value) {
    _$mStackedWidgetListundoAtom
        .reportWrite(value, super.mStackedWidgetListundo, () {
      super.mStackedWidgetListundo = value;
    });
  }

  late final _$mStackedWidgetListundo1Atom =
      Atom(name: '_AppStore.mStackedWidgetListundo1', context: context);

  @override
  List<UndoModel> get mStackedWidgetListundo1 {
    _$mStackedWidgetListundo1Atom.reportRead();
    return super.mStackedWidgetListundo1;
  }

  @override
  set mStackedWidgetListundo1(List<UndoModel> value) {
    _$mStackedWidgetListundo1Atom
        .reportWrite(value, super.mStackedWidgetListundo1, () {
      super.mStackedWidgetListundo1 = value;
    });
  }

  late final _$setDarkModeAsyncAction =
      AsyncAction('_AppStore.setDarkMode', context: context);

  @override
  Future<void> setDarkMode(bool aIsDarkMode) {
    return _$setDarkModeAsyncAction.run(() => super.setDarkMode(aIsDarkMode));
  }

  late final _$_AppStoreActionController =
      ActionController(name: '_AppStore', context: context);

  @override
  void addUndoList({UndoModel? undoModel}) {
    final _$actionInfo =
        _$_AppStoreActionController.startAction(name: '_AppStore.addUndoList');
    try {
      return super.addUndoList(undoModel: undoModel);
    } finally {
      _$_AppStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void removeUndoList() {
    final _$actionInfo = _$_AppStoreActionController.startAction(
        name: '_AppStore.removeUndoList');
    try {
      return super.removeUndoList();
    } finally {
      _$_AppStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void addRedoList({UndoModel? undoModel}) {
    final _$actionInfo =
        _$_AppStoreActionController.startAction(name: '_AppStore.addRedoList');
    try {
      return super.addRedoList(undoModel: undoModel);
    } finally {
      _$_AppStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void removeRedoList() {
    final _$actionInfo = _$_AppStoreActionController.startAction(
        name: '_AppStore.removeRedoList');
    try {
      return super.removeRedoList();
    } finally {
      _$_AppStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void addCollegeImages(File image) {
    final _$actionInfo = _$_AppStoreActionController.startAction(
        name: '_AppStore.addCollegeImages');
    try {
      return super.addCollegeImages(image);
    } finally {
      _$_AppStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearCollegeImageList() {
    final _$actionInfo = _$_AppStoreActionController.startAction(
        name: '_AppStore.clearCollegeImageList');
    try {
      return super.clearCollegeImageList();
    } finally {
      _$_AppStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setLoading(bool val) {
    final _$actionInfo =
        _$_AppStoreActionController.startAction(name: '_AppStore.setLoading');
    try {
      return super.setLoading(val);
    } finally {
      _$_AppStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
isDarkMode: ${isDarkMode},
isLoading: ${isLoading},
collegeMakerImageList: ${collegeMakerImageList},
mStackedWidgetListundo: ${mStackedWidgetListundo},
mStackedWidgetListundo1: ${mStackedWidgetListundo1}
    ''';
  }
}
