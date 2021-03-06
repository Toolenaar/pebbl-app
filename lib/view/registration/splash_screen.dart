import 'package:flutter/material.dart';
import 'package:pebbl/logic/colors.dart';
import 'package:pebbl/view/components/progress_view.dart';

class SplashScreen extends StatelessWidget {
  SplashScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.of(context).activeColorTheme().backgroundColor,
      body: Container(
        child: ProgressView(
          color: AppColors.of(context).activeColorTheme().accentColor,
        ),
      ),
    );
  }
}
