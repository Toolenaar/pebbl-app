import 'package:flutter/material.dart';

class SetCenterpiece extends StatelessWidget {
  const SetCenterpiece({Key key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width / 2;
    return Image.asset('assets/img/img_center_piece.png');
  }
}