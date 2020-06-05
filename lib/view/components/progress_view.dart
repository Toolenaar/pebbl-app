import 'package:flutter/material.dart';

class ProgressView extends StatelessWidget {
  final Color color;
  final Color backgroundColor;
  const ProgressView({this.color, this.backgroundColor = Colors.transparent});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: CircularProgressIndicator(
      valueColor: new AlwaysStoppedAnimation<Color>(color),
    ));
  }
}

class KeepSizeProgressView extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  const KeepSizeProgressView({Key key, @required this.child, @required this.isLoading}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Visibility(
            maintainSize: true,
            maintainAnimation: true,
            maintainState: true,
            visible: !isLoading,
            child: child),
        isLoading
            ? Positioned.fill(
                child: ProgressView(),
              )
            : const SizedBox()
      ],
    );
  }
}
