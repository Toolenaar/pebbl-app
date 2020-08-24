import 'package:flutter/material.dart';
import 'package:pebbl/logic/colors.dart';
import 'package:pebbl/model/category.dart';

class ThemedPebbleButton extends StatelessWidget {
  final String title;
  final Function onTap;
  final CategoryColorTheme categoryTheme;
  const ThemedPebbleButton({Key key, @required this.title, this.onTap, @required this.categoryTheme}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PebbleButton(
      title: title,
      onTap: onTap,
      backgroundColor: categoryTheme.backgroundColor,
      color: categoryTheme.accentColor,
      splashColor: categoryTheme.selectionColor,
      highlightColor: categoryTheme.highlightColor,
    );
  }
}

class PebbleButton extends StatelessWidget {
  final String title;
  final Function onTap;
  final Color backgroundColor;
  final Color color;
  final Color splashColor;
  final Color highlightColor;
  const PebbleButton(
      {Key key,
      @required this.title,
      this.onTap,
      this.splashColor,
      this.highlightColor,
      this.backgroundColor = Colors.transparent,
      this.color = AppColors.text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      child: InkWell(
        splashColor: splashColor,
        highlightColor: highlightColor,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(border: Border.all(width: 1, color: color)),
          child: Center(
              child: Text(
            title,
            style: Theme.of(context).textTheme.bodyText2.copyWith(color: color, fontSize: 14),
          )),
        ),
      ),
    );
  }
}

class PebbleTextButton extends StatelessWidget {
  final String title;
  final Function onTap;
  const PebbleTextButton({Key key, @required this.title, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.transparent),
          child: Center(
              child: Text(
            title,
            style: Theme.of(context).textTheme.bodyText2.copyWith(color: AppColors.text, fontSize: 14),
          )),
        ),
      ),
    );
  }
}
