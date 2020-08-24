import 'package:flutter/material.dart';
import 'package:pebbl/logic/colors.dart';
import 'package:pebbl/logic/date_helper.dart';
import 'package:pebbl/logic/local_notification_helper.dart';
import 'package:pebbl/logic/texts.dart';
import 'package:pebbl/model/timer_data.dart';
import 'package:pebbl/presenter/timer_presenter.dart';
import 'package:pebbl/view/components/buttons/pebble_button.dart';
import 'package:pebbl/view/home/timer/countdown_timer.dart';
import 'package:provider/provider.dart';

class ActiveTimerView extends StatefulWidget {
  final TimerData timerData;
  final Function onReset;
  ActiveTimerView({Key key, @required this.timerData, @required this.onReset}) : super(key: key);

  @override
  _ActiveTimerViewState createState() => _ActiveTimerViewState();
}

class _ActiveTimerViewState extends State<ActiveTimerView> {
  bool _active;
  TimerPresenter _presenter;

  @override
  void initState() {
    _presenter = context.read<TimerPresenter>();
    _active = widget.timerData.endTime != null;
    _presenter.updateActiveTimer(widget.timerData.copyWith());
    super.initState();
  }

  void _start() {
    context.read<LocalNotificationHelper>().sendNotification(
        'Your work is done!', 'Another job well done! Time to take a break.',
        scheduleFromNow: Duration(minutes: _presenter.activeTimer.workTime));
    _presenter.updateActiveTimer(_presenter.activeTimer.copyWith(
      endTime: DateTime.now().add(
        Duration(minutes: _presenter.activeTimer.workTime),
      ),
    ));
    setState(() {
      _active = _presenter.activeTimer.endTime != null;
    });
  }

  List<String> _getInfoData() {
    return ['Relax and enjoy the beats', 'Get shit done', 'Do some chores', 'Do some reading'];
  }

  void _reset() {
    context.read<LocalNotificationHelper>().cancelNotifications();
    _presenter.reset();
    widget.onReset();
  }

  void _stop() {
    _reset();
  }

  @override
  Widget build(BuildContext context) {
    final stopText = (widget.timerData.endTime != null && widget.timerData.endTime.isBefore(DateTime.now()))
        ? 'Start new timer'
        : 'Stop';
    final colorTheme = AppColors.getActiveColorTheme(context);
    return Container(
      child: Column(
        children: [
          BodyText2(
            'Lets go',
            fontSize: 18,
            color: colorTheme.accentColor,
          ),
          const SizedBox(height: 8),
          _presenter.activeTimer.endTime == null
              ? H1Text(
                  DateHelper.secondsToHoursMinutesSeconds(widget.timerData.workTime * 60),
                  color: colorTheme.accentColor,
                )
              : CountdownTimerView(
                  initialDisplay: DateHelper.secondsToHoursMinutesSeconds(widget.timerData.workTime * 60),
                  dateTime: _presenter.activeTimer.endTime,
                  color: colorTheme.accentColor,
                ),
          const SizedBox(height: 72),
          BodyText1(
            'HERE\'S SOME THINGS YOU CAN DO',
            color: colorTheme.accentColor,
          ),
          const SizedBox(height: 8),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: _getInfoData()
                .map(
                  (i) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: BodyText2(
                      i,
                      fontSize: 18,
                      color: colorTheme.accentColor,
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 72),
          ThemedPebbleButton(
              title: _active ? stopText : 'Start', categoryTheme: colorTheme, onTap: _active ? _stop : _start),
          FlatButton(
            child: BodyText2(
              'Reset',
              color: colorTheme.accentColor40,
            ),
            onPressed: _reset,
          )
        ],
      ),
    );
  }
}
