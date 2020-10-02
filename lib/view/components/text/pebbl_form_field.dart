import 'package:flutter/material.dart';
import 'package:pebbl/logic/colors.dart';

class PebblFormField extends StatelessWidget {
  final String hintText;
  final TextInputType keyboardType;
  final FocusNode focusNode;
  final bool obscureText;
  final String initialValue;
  final Function(String) onChanged;
  final Function(String) validator;
  const PebblFormField(
      {Key key,
      this.hintText,
      this.initialValue,
      this.keyboardType = TextInputType.text,
      this.validator,
      this.focusNode,
      this.onChanged,
      this.obscureText = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorTheme = AppColors.of(context).activeColorTheme();
    var decorator = InputDecoration(
      hintStyle: TextStyle(color: colorTheme.accentColor40),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: colorTheme.backgroundColor),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: colorTheme.accentColor, width: 1),
      ),
      border: UnderlineInputBorder(
        borderSide: BorderSide(color: colorTheme.accentColor),
      ),
    );

    return TextFormField(
        focusNode: focusNode,
        initialValue: initialValue,
        obscureText: obscureText,
        onChanged: onChanged,
        style: TextStyle(color: colorTheme.accentColor),
        validator: validator,
        keyboardType: keyboardType,
        cursorColor: colorTheme.accentColor,
        decoration: decorator.copyWith(hintText: hintText));
  }
}
