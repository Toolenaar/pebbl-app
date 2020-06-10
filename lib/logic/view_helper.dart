import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ViewHelper {
  static changeSystemOverlayStyle({Brightness brightness = Brightness.light}) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarIconBrightness: brightness, // not working
      systemNavigationBarIconBrightness: brightness, // works
    ));
  }

  static hideKeyboard(BuildContext context) {
    FocusScopeNode currentFocus = FocusScope.of(context);

    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }
}
