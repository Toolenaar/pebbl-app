import 'package:flutter/material.dart';
import 'package:pebbl/logic/colors.dart';
import 'package:pebbl/logic/texts.dart';

class BottomBar extends StatelessWidget {
  final Function(int) onTabChanged;
  final int activeIndex;
  const BottomBar({Key key, @required this.onTabChanged, this.activeIndex = 0}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Expanded(
            flex: 1,
            child: BottomBarItem(
              textAlignment: Alignment.centerLeft,
              title: 'R:Sunrays',
              onTap: () => onTabChanged(0),
              isActive: activeIndex == 0,
            )),
        Expanded(
            flex: 1,
            child: BottomBarItem(
              title: 'Infinite',
              onTap: () => onTabChanged(1),
              isActive: activeIndex == 1,
            )),
        Expanded(
          flex: 1,
          child: BottomBarItem(
            textAlignment: Alignment.centerRight,
            title: '00.00',
            onTap: () => onTabChanged(2),
            isActive: activeIndex == 2,
          ),
        )
      ],
    );
  }
}

class BottomBarItem extends StatelessWidget {
  final String title;
  final Function onTap;
  final AlignmentGeometry textAlignment;
  final bool isActive;
  const BottomBarItem(
      {Key key,
      @required this.title,
      this.isActive = false,
      @required this.onTap,
      this.textAlignment = Alignment.center})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = isActive ? Colors.white : AppColors.inactive;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Align(
          alignment: textAlignment,
          child: BodyText2(title, color: color),
        ),
      ),
    );
  }
}
