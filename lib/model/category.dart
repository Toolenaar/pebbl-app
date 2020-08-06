import 'package:flutter/material.dart';
import 'package:pebbl/logic/extensions/string.dart';

class CategoryColorTheme {
  final Color accentColor;
  final Color backgroundColor;
  final Color highlightColor;
  final Color selectionColor;

  Color get accentColor40 => accentColor.withOpacity(0.4);

  CategoryColorTheme({this.accentColor, this.backgroundColor, this.highlightColor, this.selectionColor});

  static CategoryColorTheme fromJson(Map json) {
    return CategoryColorTheme(
        accentColor: json['accentColor'].toString().toColor(),
        backgroundColor: json['backgroundColor'].toString().toColor(),
        highlightColor: json['highlightColor'].toString().toColor(),
        selectionColor: json['selectionColor'].toString().toColor());
  }
}

class Category {
  final String id;
  final String name;
  final CategoryColorTheme colorTheme;

  Category({this.id, this.name, this.colorTheme});

  static Category fromJson(Map json) {
    return Category(
      id: json['id'],
      name: json['name'],
      colorTheme: CategoryColorTheme.fromJson(json['colorTheme']),
    );
  }
}
