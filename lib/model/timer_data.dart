class TimerData {
  final String mode;
  final int workTime;
  final int breakTime;
  final DateTime breakEndTime;
  final DateTime endTime;

  TimerData({this.mode, this.workTime, this.breakTime, this.endTime, this.breakEndTime});

  TimerData copyWith({DateTime endTime, DateTime breakEndTime}) {
    return TimerData(
        mode: this.mode,
        workTime: this.workTime,
        breakTime: this.breakTime,
        endTime: endTime ?? this.endTime,
        breakEndTime: breakEndTime ?? this.breakEndTime);
  }

  Map<String, dynamic> toJson() {
    return {'mode': mode, 'workTime': workTime, 'breakTime': workTime, 'endTime': endTime?.toIso8601String() ?? null};
  }

  static TimerData fromJson(Map<String, dynamic> json) {
    final date = DateTime.parse(json['endTime']);
    final breakEndTime = json['breakEndTime'] == null ? null : DateTime.parse(json['breakEndTime']);
    return TimerData(
        breakTime: json['breakTime'],
        mode: json['mode'],
        workTime: json['workTime'],
        endTime: date,
        breakEndTime: breakEndTime);
  }

  int get activeTime {
    if (mode == 'pomodoro') {
      if (endTime == null && breakEndTime == null) return workTime;
      if (endTime != null && endTime.isAfter(DateTime.now())) return workTime;
      if (breakEndTime == null) return breakTime;
      if (breakEndTime.isAfter(DateTime.now())) return breakTime;
    }

    return workTime;
  }

  DateTime get activeEndTime {
    if (mode == 'pomodoro') {
      if (endTime == null && breakEndTime == null) return endTime;
      if (endTime != null && endTime.isAfter(DateTime.now())) return endTime;
      if (breakEndTime == null) return breakEndTime;
      if (breakEndTime.isAfter(DateTime.now())) return breakEndTime;
    }

    return endTime;
  }

  bool get needsAbreak {
    if (mode == 'pomodoro') {
      if (endTime == null && breakEndTime == null) return false;
      if (endTime != null && endTime.isAfter(DateTime.now())) return false;
      if (breakEndTime == null) return true;
      if (breakEndTime.isAfter(DateTime.now())) return false; //currently having a break
    }
    return false;
  }
}

class Minute {
  final int value;

  Minute(this.value);

  @override
  String toString() {
    return '$value min';
  }
}
