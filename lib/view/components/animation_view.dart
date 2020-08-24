import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AnimationView extends StatelessWidget {
  final String animationFile;
  const AnimationView({Key key, @required this.animationFile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      //color: Colors.blue.withOpacity(0.3),
      child: Lottie.asset(
        animationFile,
        fit: BoxFit.fill,
      ),
    );
  }
}
