import 'dart:async';

import 'package:pebbl/logic/date_helper.dart';
import 'package:pebbl/logic/storage.dart';
import 'package:pebbl/model/timer_data.dart';
import 'package:rxdart/rxdart.dart';

class TimerPresenter {
  TimerData get activeTimer => _activeTimer.value;
  final BehaviorSubject<TimerData> _activeTimer = BehaviorSubject.seeded(null);
  ValueStream<TimerData> get activeTimerStream => _activeTimer.stream;

  final BehaviorSubject<String> _timeDisplay = BehaviorSubject.seeded(null);
  ValueStream<String> get timeDisplayStream => _timeDisplay.stream;

  Timer timer;

  Future init() async {
    if (timer != null) timer.cancel();
    await loadTimer();
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setTime();
    });
  }

  void setTime() {
    var timeDisplay = '00:00:00';
    var timeData = _activeTimer.value;
    if (timeData == null) {
      _timeDisplay.add(timeDisplay);
      return;
    }

    if (timeData.endTime == null) {
      timeDisplay = DateHelper.secondsToHoursMinutesSeconds(timeData.activeTime * 60);
    } else if (timeData.endTime.isBefore(DateTime.now())) {
      //timer is over
      timeDisplay = '00:00:00';
      // if pomodoro show break timer
      final breakTime = setBreakTime(timeData);
      if (breakTime != null) timeDisplay = breakTime;
    } else {
      //show remaining time
      final seconds = timeData.endTime.difference(DateTime.now()).inSeconds;
      timeDisplay = DateHelper.secondsToHoursMinutesSeconds(seconds);
    }
    _timeDisplay.add(timeDisplay);
  }

  String setBreakTime(TimerData timeData) {
    if (timeData.mode != 'pomodoro') return null;
    if (timeData.breakEndTime == null) {
      return DateHelper.secondsToHoursMinutesSeconds(timeData.breakTime * 60);
    } else if (timeData.breakEndTime.isBefore(DateTime.now())) {
      //timer is over
      return '00:00:00';
    } else {
      //show remaining time
      final seconds = timeData.breakEndTime.difference(DateTime.now()).inSeconds;
      return DateHelper.secondsToHoursMinutesSeconds(seconds);
    }
  }

  Future loadTimer() async {
    final activeTimer = await LocalStorage.loadTimerData();
    if (activeTimer != null && activeTimer.endTime.isAfter(DateTime.now())) {
      _activeTimer.add(activeTimer);
    } else {
      LocalStorage.saveTimerData(null);
    }
  }

  Future updateActiveTimer(TimerData data) async {
    _activeTimer.add(data);
    LocalStorage.saveTimerData(data);
  }

  void reset() {
    _activeTimer.add(null);
  }
}
