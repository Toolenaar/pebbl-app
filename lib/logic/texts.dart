import 'package:flutter/material.dart';

class H1Text extends StatelessWidget {
  final String text;
  final Color color;
  final double fontSize;
  const H1Text(this.text, {Key key, this.color = Colors.white, this.fontSize}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.headline4.copyWith(color: color, fontSize: fontSize),
    );
  }
}

class BodyText2 extends StatelessWidget {
  final String text;
  final Color color;
  final double fontSize;
  final FontWeight fontWeight;
  final FontStyle fontStyle;
  const BodyText2(this.text, {Key key, this.color = Colors.white, this.fontSize, this.fontStyle, this.fontWeight})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).textTheme.bodyText2;
    return Text(
      text,
      style: base.copyWith(
          color: color,
          fontSize: fontSize,
          fontStyle: fontStyle ?? base.fontStyle,
          fontWeight: fontWeight ?? base.fontWeight),
    );
  }
}

class BodyText1 extends StatelessWidget {
  final String text;
  final Color color;
  final double fontSize;
  const BodyText1(this.text, {Key key, this.color = Colors.white, this.fontSize}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style:
          Theme.of(context).textTheme.bodyText1.copyWith(color: color, fontSize: fontSize, fontWeight: FontWeight.bold),
    );
  }
}

class SubtitleText2 extends StatelessWidget {
  final String text;
  final Color color;
  final double fontSize;
  const SubtitleText2(this.text, {Key key, this.color = Colors.white, this.fontSize}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.subtitle2.copyWith(color: color, fontSize: fontSize),
    );
  }
}
