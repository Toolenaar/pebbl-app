import 'package:flutter/material.dart';
import 'package:pebbl/logic/colors.dart';
import 'package:pebbl/logic/texts.dart';
import 'package:pebbl/model/audio_set.dart';
import 'package:pebbl/presenter/sets_presenter.dart';
import 'package:provider/provider.dart';

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
              child: ActiveSetBottomBarItem(isActive: activeIndex == 0),
              textAlignment: Alignment.centerLeft,
              onTap: () => onTabChanged(0),
            )),
        Expanded(
          flex: 1,
          child: BottomBarItem(
            child: TextBottomBarItem(
              title: 'Infinite',
              isActive: activeIndex == 1,
            ),
            onTap: () => onTabChanged(1),
          ),
        ),
        Expanded(
          flex: 1,
          child: BottomBarItem(
            child: TextBottomBarItem(
              title: 'Favorites',
              isActive: activeIndex == 2,
            ),
            textAlignment: Alignment.centerRight,
            onTap: () => onTabChanged(2),
          ),
        )
      ],
    );
  }
}

class BottomBarItem extends StatelessWidget {
  final Function onTap;
  final AlignmentGeometry textAlignment;
  final Widget child;
  const BottomBarItem({Key key, @required this.child, @required this.onTap, this.textAlignment = Alignment.center})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Align(
          alignment: textAlignment,
          child: child,
        ),
      ),
    );
  }
}

class TextBottomBarItem extends StatelessWidget {
  final String title;
  final bool isActive;
  const TextBottomBarItem({Key key, this.isActive = false, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorTheme = AppColors.getActiveColorTheme(context);
    final color = isActive ? colorTheme.accentColor : colorTheme.accentColor40;
    return BodyText2(title, color: color);
  }
}

class ActiveSetBottomBarItem extends StatelessWidget {
  final bool isActive;
  const ActiveSetBottomBarItem({Key key, this.isActive = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorTheme = AppColors.getActiveColorTheme(context);
    final color = isActive ? colorTheme.accentColor : colorTheme.accentColor40;
    final activeSet = context.select<SetsPresenter, AudioSet>((value) => value.activeSet);
    return FittedBox(fit: BoxFit.fitWidth, child: BodyText2(activeSet?.fullName ?? 'P: Empty', color: color));
  }
}
