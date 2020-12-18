import 'package:flutter/material.dart';
import 'package:pebbl/logic/colors.dart';
import 'package:pebbl/logic/date_helper.dart';
import 'package:pebbl/logic/texts.dart';
import 'package:pebbl/model/category.dart';
import 'package:pebbl/model/timer_data.dart';
import 'package:pebbl/presenter/sets_presenter.dart';
import 'package:pebbl/presenter/timer_presenter.dart';
import 'package:pebbl/view/home/timer/countdown_timer.dart';
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
          ),
        ),
        Expanded(
          flex: 1,
          child: BottomBarItem(
            child: TimerBottomBarItem(
              title: 'Timer',
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
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        child: Align(
          alignment: textAlignment,
          child: child,
        ),
      ),
    );
  }
}

class TimerBottomBarItem extends StatefulWidget {
  final String title;
  final bool isActive;
  const TimerBottomBarItem({Key key, this.isActive = false, this.title}) : super(key: key);

  @override
  _TimerBottomBarItemState createState() => _TimerBottomBarItemState();
}

class _TimerBottomBarItemState extends State<TimerBottomBarItem> {
  TimerPresenter _presenter;

  @override
  void initState() {
    _presenter = context.read<TimerPresenter>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final colorTheme = AppColors.of(context).activeColorTheme();
    final color = widget.isActive ? colorTheme.accentColor : colorTheme.accentColor40;

    return StreamBuilder<TimerData>(
      stream: _presenter.activeTimerStream,
      initialData: null,
      builder: (BuildContext context, AsyncSnapshot<TimerData> snapshot) {
        if (snapshot.data == null) return BodyText2(widget.title, color: color);
        if (snapshot.data.endTime == null)
          return BodyText2(DateHelper.secondsToHoursMinutesSeconds(snapshot.data.workTime * 60), color: color);

        return CountdownTimerView(
          fontSize: 14,
          color: color,
        );
      },
    );
  }
}

class TextBottomBarItem extends StatelessWidget {
  final String title;
  final bool isActive;
  const TextBottomBarItem({Key key, this.isActive = false, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorTheme = AppColors.of(context).activeColorTheme();
    final color = isActive ? colorTheme.accentColor : colorTheme.accentColor40;
    return BodyText2(title, color: color);
  }
}

class ActiveSetBottomBarItem extends StatelessWidget {
  final bool isActive;
  const ActiveSetBottomBarItem({Key key, this.isActive = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorTheme = AppColors.of(context).activeColorTheme();
    final color = isActive ? colorTheme.accentColor : colorTheme.accentColor40;
    final activeCat = context.select<SetsPresenter, Category>((value) => value.activeCategory);
    return FittedBox(fit: BoxFit.fitWidth, child: BodyText2(activeCat?.name ?? 'P: Empty', color: color));
  }
}
