import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:pebbl/model/audio_set.dart';
import 'package:pebbl/model/category.dart';
import 'package:pebbl/presenter/sets_presenter.dart';

class AppColors {
  static const Color background = Color(0xFF222224);
  static const Color inactive = Color(0xFF9898A0);
  static const Color text = Color(0xFFFFFEF9);
  static const Color text70 = Color(0xB3FFFEF9);
  static CategoryColorTheme colorTheme = CategoryColorTheme(
      backgroundColor: Color(0xFF252C26),
      accentColor: Color(0xFF658E6C),
      selectionColor: Color(0xFF353835),
      highlightColor: Color(0xFF3E5342));

  static CategoryColorTheme getActiveColorTheme(BuildContext context) {
    return context.select<SetsPresenter, CategoryColorTheme>((value) => value.activeColorTheme);
  }
}
