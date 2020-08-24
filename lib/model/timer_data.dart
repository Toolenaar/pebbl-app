class TimerData {
  final String mode;
  final int workTime;
  final int breakTime;
  final DateTime endTime;

  TimerData({this.mode, this.workTime, this.breakTime, this.endTime});

  TimerData copyWith({DateTime endTime}) {
    return TimerData(
        mode: this.mode, workTime: this.workTime, breakTime: this.breakTime, endTime: endTime ?? this.endTime);
  }

  Map<String, dynamic> toJson() {
    return {'mode': mode, 'workTime': workTime, 'breakTime': workTime, 'endTime': endTime.toIso8601String()};
  }

  static TimerData fromJson(Map<String, dynamic> json) {
    final date = DateTime.parse(json['endTime']);
    return TimerData(breakTime: json['breakTime'], mode: json['mode'], workTime: json['workTime'], endTime: date);
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
