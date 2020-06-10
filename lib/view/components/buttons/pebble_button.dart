import 'package:flutter/material.dart';
import 'package:pebbl/logic/colors.dart';

class PebbleButton extends StatelessWidget {
  final String title;
  final Function onTap;
  const PebbleButton({Key key, @required this.title, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration:
              BoxDecoration(color: Colors.transparent, border: Border.all(width: 1, color: AppColors.text)),
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
          decoration:
              BoxDecoration(color: Colors.transparent),
          child: Center(
              child: Text(
            title,
            style: Theme.of(context).textTheme.bodyText2.copyWith(color:  AppColors.text, fontSize: 14),
          )),
        ),
      ),
    );
  }
}