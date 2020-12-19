import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:pebbl/logic/colors.dart';

class AnimationView extends StatelessWidget {
  final String animationFile;
  final Color color;
  const AnimationView({Key key, @required this.animationFile, this.color = Colors.transparent}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      //color: Colors.blue.withOpacity(0.3),
      child: Lottie.asset(
        animationFile,
        fit: BoxFit.fill,
        delegates: LottieDelegates(
          values: [
            ValueDelegate.strokeColor(
              const ['**'],
              value: color,
            ),
            // ValueDelegate.strokeColor(
            //   const ['Group 8', '**'],
            //   value: color,
            // ),
            // ValueDelegate.strokeColor(
            //   const ['Group 7', '**'],
            //   value: Colors.yellow,
            // ),
            // ValueDelegate.strokeColor(
            //   const ['rain splash 7', '**'],
            //   value: Colors.yellow,
            // ),
            // ValueDelegate.strokeColor(
            //   const ['rain splash 6', '**'],
            //   value: Colors.yellow,
            // ),
            // ValueDelegate.strokeColor(
            //   const ['rain splash 5', '**'],
            //   value: Colors.yellow,
            // ),
            // ValueDelegate.strokeColor(
            //   const ['rain splash 4', '**'],
            //   value: Colors.yellow,
            // ),
            // ValueDelegate.strokeColor(
            //   const ['rain splash 3', '**'],
            //   value: Colors.yellow,
            // ),
            // ValueDelegate.strokeColor(
            //   const ['rain splash 2', '**'],
            //   value: Colors.yellow,
            // ),
            // ValueDelegate.strokeColor(
            //   const ['rain splash 1', '**'],
            //   value: Colors.yellow,
            // ),
            // ValueDelegate.strokeColor(
            //   const ['rain precomp 1', '**'],
            //   value: Colors.yellow,
            // ),
            // ValueDelegate.strokeColor(
            //   const ['rain precomp 1', '**'],
            //   value: Colors.yellow,
            // ),
          ],
        ),
      ),
    );
  }

  String _getAnimationForTheme(BuildContext context) {
    final theme = AppColors.of(context).activeColorTheme();
    return animationFile.replaceFirst('.json', '_${theme.id}.json');
  }
}
