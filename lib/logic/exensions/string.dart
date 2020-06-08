//https://github.com/felixblaschke/supercharged/blob/master/lib/string/string.dart

import 'package:flutter/material.dart';
import 'package:pebbl/logic/exensions/error.dart';

extension String_ on String {
  /// Converts string in hex representation into a [Color].
  ///
  /// You can use 6-char hex color (RRGGBB), 3-char hex color (RGB) or a valid
  /// HTML color name. The hash (#) is optional for hex color strings.
  ///
  /// Example:
  /// ```dart
  /// "#ff00ff".toColor();  // pink
  /// "ff0000".toColor();   // red
  /// "00f".toColor();      // blue
  /// "red".toColor();      // red (HTML color name)
  /// "deeppink".toColor(); // deep pink (HTML color name)
  /// ```
  ///
  Color toColor() {
    try {
      var color = _removeLeadingHash(this);
      if (color.length == 6) {
        return _sixCharHexToColor(color);
      }
      if (color.length == 3) {
        return _threeCharHexToColor(color);
      }
    } catch (error) {
      // will throw anyway
    }
    throw ArgumentError("Can not interpret string $this");
  }

  static String _removeLeadingHash(String color) {
    if (color.startsWith("#")) {
      return color.substring(1);
    }
    return color;
  }

  static Color _sixCharHexToColor(String color) {
    var r = color.substring(0, 2).toInt(radix: 16);
    var g = color.substring(2, 4).toInt(radix: 16);
    var b = color.substring(4, 6).toInt(radix: 16);
    return Color.fromARGB(255, r, g, b);
  }

  static Color _threeCharHexToColor(String color) {
    var r = color.substring(0, 1).repeat(2).toInt(radix: 16);
    var g = color.substring(1, 2).repeat(2).toInt(radix: 16);
    var b = color.substring(2, 3).repeat(2).toInt(radix: 16);
    return Color.fromARGB(255, r, g, b);
  }

    /// Parses string and returns integer value.
  ///
  /// You can set an optional [radix] to specify the numeric base.
  /// If no [radix] is set, it will use the decimal system (10).
  ///
  /// Returns `null` if parsing fails.
  ///
  /// Example:
  /// ```dart
  /// "42".toDouble();      // 42
  /// "invalid".toDouble(); // null
  int toInt({int radix = 10}) {
    try {
      return int.parse(this, radix: radix);
    } catch (error) {
      return null;
    }
  }

  /// Repeats the string [n] times
  ///
  /// You can set an optional [separator] that is put in between each repetition
  ///
  /// Example:
  /// ```dart
  /// "hello".repeat(2);                // "hellohello"
  /// "cat".repeat(3, separator: ":");  // "cat:cat:cat"
  /// ```
  String repeat(int n, {String separator = ""}) {
    ArgumentError.checkNotNull(n, "n");
    throwIfNot(n > 0, () => ArgumentError("n must be a positive value greater then 0"));

    var repeatedString = "";

    for (int i = 0; i < n; i++) {
      if (i > 0) {
        repeatedString += separator;
      }
      repeatedString += this;
    }

    return repeatedString;
  }
}
