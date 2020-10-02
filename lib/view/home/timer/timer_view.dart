import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pebbl/logic/colors.dart';
import 'package:pebbl/logic/texts.dart';
import 'package:pebbl/model/timer_data.dart';
import 'package:pebbl/presenter/timer_presenter.dart';
import 'package:pebbl/view/components/buttons/pebble_button.dart';
import 'package:pebbl/view/components/scroll_picker.dart';
import 'package:pebbl/view/home/timer/active_timer_view.dart';
import 'package:provider/provider.dart';

class TimerView extends StatefulWidget {
  final Function onCloseTap;
  const TimerView({Key key, this.onCloseTap}) : super(key: key);

  @override
  _TimerViewState createState() => _TimerViewState();
}

class _TimerViewState extends State<TimerView> {
  String _mode = 'timer';

  Minute _selectedBreakTime = Minute(5);
  Minute _selectedWorkTime = Minute(5);

  TimerData _timerData;

  @override
  void initState() {
    _timerData = context.read<TimerPresenter>().activeTimer;
    super.initState();
  }

  void _setTimer() {
    //save time data
    setState(() {
      _timerData =
          TimerData(endTime: null, mode: _mode, workTime: _selectedWorkTime.value, breakTime: _selectedBreakTime.value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeTimer = Provider.of<TimerPresenter>(context, listen: false).activeTimer;
    return _timerData != null
        ? Expanded(
            child: ActiveTimerView(
              onCloseTap: widget.onCloseTap,
              onReset: () {
                setState(() {
                  _timerData = null;
                });
              },
              timerData: _timerData,
            ),
          )
        : TimerSetupView(
            mode: _mode,
            modeChanged: (mode) {
              setState(() {
                _mode = mode;
              });
            },
            initialBreakTimeValue: _selectedBreakTime,
            initialWorkTimeValue: _selectedWorkTime,
            initialTimeValue: _selectedWorkTime,
            setTime: _setTimer,
            breakTimePicked: (breakTime) {
              setState(() {
                _selectedBreakTime = breakTime;
              });
            },
            workTimePicked: (workTime) {
              setState(() {
                _selectedWorkTime = workTime;
              });
            },
            timePicked: (value) {
              setState(() {
                _selectedWorkTime = value;
              });
            },
          );
  }
}

class TimerSetupView extends StatelessWidget {
  final Function(Minute) timePicked;
  final Minute initialTimeValue;

  final Function(Minute) workTimePicked;
  final Minute initialWorkTimeValue;

  final Function(Minute) breakTimePicked;
  final Minute initialBreakTimeValue;

  final Function setTime;
  final String mode;
  final Function(String) modeChanged;

  const TimerSetupView(
      {Key key,
      @required this.timePicked,
      @required this.initialTimeValue,
      @required this.workTimePicked,
      @required this.initialWorkTimeValue,
      @required this.breakTimePicked,
      @required this.setTime,
      @required this.mode,
      @required this.modeChanged,
      @required this.initialBreakTimeValue})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorTheme = AppColors.of(context).activeColorTheme();
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TimerModeToggle(selectedMode: mode, onModeChanged: modeChanged),
          const SizedBox(height: 16),
          if (mode == 'timer')
            NormalTimerSelector(
                minutes: [Minute(1), Minute(5), Minute(10), Minute(30), Minute(60)],
                initialValue: initialTimeValue,
                timePicked: timePicked),
          if (mode == 'pomodoro')
            PomodoroTimerSelector(
              workMinutes: [Minute(1), Minute(5), Minute(10), Minute(30), Minute(60)],
              breakMinutes: [Minute(1), Minute(5), Minute(10), Minute(15), Minute(20)],
              breakTimePicked: breakTimePicked,
              workTimePicked: workTimePicked,
              initialBreakTimeValue: initialBreakTimeValue,
              initialWorkTimeValue: initialWorkTimeValue,
            ),
          const SizedBox(
            height: 16,
          ),
          ThemedPebbleButton(title: 'Set timer', categoryTheme: colorTheme, onTap: setTime)
        ],
      ),
    );
  }
}

class TimerModeToggle extends StatelessWidget {
  final Function(String) onModeChanged;
  final String selectedMode;
  const TimerModeToggle({Key key, @required this.onModeChanged, @required this.selectedMode}) : super(key: key);

  Widget _buildButton({String mode, String title, BuildContext context, bool last = false}) {
    final colorTheme = AppColors.of(context).activeColorTheme();
    return Expanded(
      child: GestureDetector(
        onTap: () => onModeChanged(mode),
        child: Container(
          decoration: BoxDecoration(
              color: selectedMode == mode ? colorTheme.highlightColor : colorTheme.backgroundColor,
              border: Border(
                left: BorderSide(width: 1, color: colorTheme.accentColor),
                top: BorderSide(width: 1, color: colorTheme.accentColor),
                bottom: BorderSide(width: 1, color: colorTheme.accentColor),
                right: BorderSide(width: last ? 1 : 0, color: colorTheme.accentColor),
              )),
          height: 72,
          child: Center(
            child: BodyText2(
              title,
              color: colorTheme.accentColor,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorTheme = AppColors.of(context).activeColorTheme();
    return Container(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BodyText1('TIMER MODE', color: colorTheme.accentColor),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildButton(mode: 'timer', title: 'Normal Timer', context: context),
            _buildButton(mode: 'pomodoro', title: 'Pomodoro', context: context, last: true)
          ],
        )
      ],
    ));
  }
}

class NormalTimerSelector extends StatelessWidget {
  final Function(Minute) timePicked;
  final Minute initialValue;
  final List<Minute> minutes;
  const NormalTimerSelector({Key key, @required this.timePicked, @required this.initialValue, @required this.minutes})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorTheme = AppColors.of(context).activeColorTheme();
    return Container(
        decoration: BoxDecoration(
            color: colorTheme.backgroundColor, border: Border.all(width: 1, color: colorTheme.accentColor)),
        height: 200,
        child: ScrollPicker(
          onChanged: (value) {
            timePicked(minutes.firstWhere((e) => e.toString() == value));
          },
          initialValue: initialValue.toString(),
          items: minutes.map((e) => e.toString()).toList(),
        ));
  }
}

class PomodoroTimerSelector extends StatelessWidget {
  final Function(Minute) workTimePicked;
  final Minute initialWorkTimeValue;

  final Function(Minute) breakTimePicked;
  final Minute initialBreakTimeValue;

  final List<Minute> workMinutes;
  final List<Minute> breakMinutes;
  const PomodoroTimerSelector(
      {Key key,
      @required this.workMinutes,
      @required this.breakMinutes,
      @required this.workTimePicked,
      @required this.initialWorkTimeValue,
      @required this.breakTimePicked,
      @required this.initialBreakTimeValue})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorTheme = AppColors.of(context).activeColorTheme();
    return Container(
      // decoration: BoxDecoration(border: Border.all(width: 1, color: colorTheme.accentColor)),
      height: 200,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                BodyText1('WORK TIME', color: colorTheme.accentColor),
                const SizedBox(height: 16),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                        color: colorTheme.backgroundColor,
                        border: Border(
                          left: BorderSide(width: 1, color: colorTheme.accentColor),
                          right: BorderSide(width: 1, color: colorTheme.accentColor),
                          top: BorderSide(width: 1, color: colorTheme.accentColor),
                          bottom: BorderSide(width: 1, color: colorTheme.accentColor),
                        )),
                    child: ScrollPicker(
                      onChanged: (value) {
                        workTimePicked(workMinutes.firstWhere((e) => e.toString() == value));
                      },
                      initialValue: initialWorkTimeValue.toString(),
                      items: workMinutes.map((e) => e.toString()).toList(),
                    ),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                BodyText1(
                  'BREAK TIME',
                  color: colorTheme.accentColor,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                        color: colorTheme.backgroundColor,
                        border: Border(
                          right: BorderSide(width: 1, color: colorTheme.accentColor),
                          top: BorderSide(width: 1, color: colorTheme.accentColor),
                          bottom: BorderSide(width: 1, color: colorTheme.accentColor),
                        )),
                    child: ScrollPicker(
                      onChanged: (value) {
                        breakTimePicked(breakMinutes.firstWhere((e) => e.toString() == value));
                      },
                      initialValue: initialBreakTimeValue.toString(),
                      items: breakMinutes.map((e) => e.toString()).toList(),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
