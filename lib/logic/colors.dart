import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:pebbl/logic/storage.dart';
import 'package:pebbl/model/category.dart';
import 'package:rxdart/rxdart.dart';

class AppColors extends InheritedWidget {
  const AppColors({
    Key key,
    @required this.controller,
    @required Widget child,
  })  : assert(controller != null),
        assert(child != null),
        super(key: key, child: child);

  final AppColorsController controller;
  CategoryColorTheme activeColorTheme() {
    //todo check if night
    return controller.activeColorTheme();
  }

  static AppColors of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppColors>();
  }

  @override
  bool updateShouldNotify(AppColors old) {
    return old.controller.activeNightColorTheme != controller.activeNightColorTheme;
  }
}

class AppColorsController {
  static CategoryColorTheme defaultDayColorTheme = ColorThemes.dayThemes[0];
  static CategoryColorTheme defaultNightColorTheme = ColorThemes.nightThemes[0];

  final BehaviorSubject<CategoryColorTheme> activeColorThemeSubject = BehaviorSubject.seeded(null);
  ValueStream<CategoryColorTheme> get activeColorThemeStream => activeColorThemeSubject.stream;

  bool initialized = false;

  Future init(BuildContext context) async {
    final dayId = await LocalStorage.getString(LocalStorage.DAY_THEME_KEY);
    if (dayId != null) {
      activeDayColorTheme = ColorThemes.dayThemes.firstWhere((e) => e.id == dayId);
    }
    if (activeDayColorTheme == null) activeDayColorTheme = AppColorsController.defaultDayColorTheme;

    final nightId = await LocalStorage.getString(LocalStorage.NIGHT_THEME_KEY);
    if (nightId != null) {
      activeNightColorTheme = ColorThemes.nightThemes.firstWhere((e) => e.id == nightId);
    }
    if (activeNightColorTheme == null) activeNightColorTheme = AppColorsController.defaultNightColorTheme;

    initialized = true;
  }

  CategoryColorTheme activeDayColorTheme;
  CategoryColorTheme activeNightColorTheme;
  CategoryColorTheme activeColorTheme() {
    //todo check if night
    return isNight() ? activeNightColorTheme : activeDayColorTheme;
  }

  bool isNight() {
    return DateTime.now().hour > 17;
  }

  void setActiveDayColor(CategoryColorTheme theme) {
    activeDayColorTheme = theme;
    activeColorThemeSubject.add(activeColorTheme());
  }

  void setActiveNightColor(CategoryColorTheme theme) {
    activeNightColorTheme = theme;
    activeColorThemeSubject.add(activeColorTheme());
  }
}

class ColorThemes {
  static List<CategoryColorTheme> dayThemes = [
    CategoryColorTheme(
      id: 'd1',
      backgroundColor: Color(0xFFFFB19A),
      accentColor: Color(0xFFFF3636),
      highlightColor: Color(0xFFF9C4B5),
      selectionColor: Color(0xFFFFC4B5),
    ),
    CategoryColorTheme(
      id: 'd2',
      backgroundColor: Color(0xFF252C26),
      accentColor: Color(0xFF707070),
      highlightColor: Color(0xFF353835),
      selectionColor: Color(0xFF353835),
    ),
    CategoryColorTheme(
      id: 'd3',
      backgroundColor: Color(0xFFE4B42F),
      accentColor: Color(0xFFFFFFFF),
      highlightColor: Color(0xFFE8C35C),
      selectionColor: Color(0xFFE8C35C),
    )
  ];
  static List<CategoryColorTheme> nightThemes = [
    CategoryColorTheme(
      id: 'n1',
      backgroundColor: Color(0xFF252C26),
      accentColor: Color(0xFF707070),
      highlightColor: Color(0xFF353835),
      selectionColor: Color(0xFF353835),
    ),
    CategoryColorTheme(
      id: 'n2',
      backgroundColor: Color(0xFF3E5771),
      accentColor: Color(0xFF3A3E43),
      highlightColor: Color(0xFF424D58),
      selectionColor: Color(0xFF424D58),
    )
  ];
}
