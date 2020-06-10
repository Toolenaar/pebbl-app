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

  static InputDecoration decorator = InputDecoration(
    hintStyle: TextStyle(color: AppColors.text70),
    enabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: AppColors.text),
    ),
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: AppColors.text, width: 1),
    ),
    border: UnderlineInputBorder(
      borderSide: BorderSide(color: AppColors.text),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        focusNode: focusNode,
        initialValue: initialValue,
        obscureText: obscureText,
        onChanged: onChanged,
        style: TextStyle(color: AppColors.text),
        validator: validator,
        keyboardType: keyboardType,
        cursorColor: AppColors.text,
        decoration: decorator.copyWith(hintText: hintText));
  }
}
