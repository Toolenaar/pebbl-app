import 'package:pebbl/logic/storage.dart';
import 'package:pebbl/model/timer_data.dart';
import 'package:rxdart/rxdart.dart';

class TimerPresenter {
  TimerData get activeTimer => _activeTimer.value;
  final BehaviorSubject<TimerData> _activeTimer = BehaviorSubject.seeded(null);
  ValueStream<TimerData> get activeTimerStream => _activeTimer.stream;

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
