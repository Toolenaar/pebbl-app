import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:pebbl/logic/colors.dart';

class AnimationView extends StatelessWidget {
  final String animationFile;
  const AnimationView({Key key, @required this.animationFile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      //color: Colors.blue.withOpacity(0.3),
      child: Lottie.asset(
        _getAnimationForTheme(context),
        fit: BoxFit.fill,
        // delegates: LottieDelegates(values: [
        //   ValueDelegate.color(
        //     const [
        //       '**',
        //     ],
        //     value: Colors.yellow,
        //   ),
        // ]),
      ),
    );
  }

  String _getAnimationForTheme(BuildContext context) {
    final theme = AppColors.of(context).activeColorTheme();
    return animationFile.replaceFirst('.json', '_${theme.id}.json');
  }
}
