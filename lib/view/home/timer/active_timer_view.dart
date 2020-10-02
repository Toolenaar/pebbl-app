import 'package:flutter/material.dart';
import 'package:pebbl/logic/colors.dart';
import 'package:pebbl/logic/local_notification_helper.dart';
import 'package:pebbl/logic/storage.dart';
import 'package:pebbl/logic/texts.dart';
import 'package:pebbl/model/timer_data.dart';
import 'package:pebbl/presenter/timer_presenter.dart';
import 'package:pebbl/view/components/buttons/pebble_button.dart';
import 'package:pebbl/view/home/timer/countdown_timer.dart';
import 'package:provider/provider.dart';

class ActiveTimerView extends StatefulWidget {
  final TimerData timerData;
  final Function onReset;
  final Function onCloseTap;
  ActiveTimerView({Key key, @required this.timerData, @required this.onReset, this.onCloseTap}) : super(key: key);

  @override
  _ActiveTimerViewState createState() => _ActiveTimerViewState();
}

class _ActiveTimerViewState extends State<ActiveTimerView> {
  bool _active;
  TimerPresenter _presenter;
  Stream<String> countdownTimeStream;
  TimerData _timerData;

  @override
  void initState() {
    _timerData = widget.timerData;
    countdownTimeStream = context.read<TimerPresenter>().timeDisplayStream;
    _presenter = context.read<TimerPresenter>();
    _active = _timerData.endTime != null;
    _presenter.updateActiveTimer(_timerData = _timerData.copyWith());
    super.initState();
  }

  void _start() {
    context.read<LocalNotificationHelper>().sendNotification(
        'Your work is done!', 'Another job well done! Time to take a break.',
        scheduleFromNow: Duration(minutes: _presenter.activeTimer.workTime));

    _timerData = _presenter.activeTimer.copyWith(
      endTime: DateTime.now().add(
        Duration(minutes: _presenter.activeTimer.workTime),
      ),
    );

    _presenter.updateActiveTimer(_timerData);
    setState(() {
      _active = _presenter.activeTimer.endTime != null;
    });
  }

  List<String> _getInfoData({bool needsAbreak = false}) {
    if (needsAbreak) return ['Make a cup of thee', 'Do a workout', 'Grab a bite to eat'];
    return ['Relax and enjoy the beats', 'Get shit done', 'Do some chores', 'Do some reading'];
  }

  void _startBreak() {
    context.read<LocalNotificationHelper>().sendNotification('Break is over!', 'Alright back to work!',
        scheduleFromNow: Duration(minutes: _presenter.activeTimer.workTime));
    _timerData = _timerData.copyWith(
      breakEndTime: DateTime.now().add(
        Duration(minutes: _timerData.breakTime),
      ),
    );
    _presenter.updateActiveTimer(_timerData);
    setState(() {
      _active = true;
    });
  }

  void _reset() {
    context.read<LocalNotificationHelper>().cancelNotifications();
    _presenter.reset();
    widget.onReset();
  }

  void _stop() {
    if (_timerData.needsAbreak) {
      _startBreak();
      return;
    }
    _reset();
  }

  String _stopText() {
    var stopText = 'stop';
    if (_timerData.endTime != null && (_timerData.endTime.isBefore(DateTime.now()))) {
      stopText = 'Start new timer';
    }
    if (_timerData.needsAbreak) {
      stopText = 'Start break timer';
    }

    return stopText;
  }

  void _autoStartBreak() async {
    if (_timerData.needsAbreak) {
      final autoBreakTime = await LocalStorage.getbool(LocalStorage.AUTO_BREAK_TIMER_KEY) ?? false;
      if (autoBreakTime) {
        _startBreak();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorTheme = AppColors.of(context).activeColorTheme();
    return StreamBuilder<String>(
      stream: countdownTimeStream,
      initialData: '',
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        _autoStartBreak();
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            // mainAxisSize: MainAxisSize.min,
            children: [
              if (_timerData.needsAbreak)
                Expanded(
                  child: Column(
                    children: [
                      const SizedBox(height: 64),
                      BodyText2(
                        'Time for a short break',
                        fontSize: 24,
                        color: colorTheme.accentColor,
                      ),
                      const SizedBox(height: 8),
                      CountdownTimerView(
                        time: snapshot.data,
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
                        children: _getInfoData(needsAbreak: _timerData.needsAbreak)
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
                    ],
                  ),
                ),
              if (!_timerData.needsAbreak)
                Expanded(
                  child: GestureDetector(
                    onTap: widget.onCloseTap,
                    child: Container(
                      color: Colors.transparent,
                    ),
                  ),
                ),
              // BodyText2(
              //   _timerData.needsAbreak ? 'Take a break' : 'Lets go',
              //   fontSize: 18,
              //   color: colorTheme.accentColor,
              // ),
              // const SizedBox(height: 8),
              // CountdownTimerView(
              //   time: snapshot.data,
              //   color: colorTheme.accentColor,
              // ),
              // const SizedBox(height: 72),
              // BodyText1(
              //   'HERE\'S SOME THINGS YOU CAN DO',
              //   color: colorTheme.accentColor,
              // ),
              // const SizedBox(height: 8),
              // Column(
              //   mainAxisSize: MainAxisSize.min,
              //   children: _getInfoData(needsAbreak: _timerData.needsAbreak)
              //       .map(
              //         (i) => Padding(
              //           padding: const EdgeInsets.symmetric(vertical: 4),
              //           child: BodyText2(
              //             i,
              //             fontSize: 18,
              //             color: colorTheme.accentColor,
              //           ),
              //         ),
              //       )
              //       .toList(),
              // ),
              const SizedBox(height: 32),
              ThemedPebbleButton(
                  title: _active ? _stopText() : 'Start', categoryTheme: colorTheme, onTap: _active ? _stop : _start),
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
      },
    );
  }
}
