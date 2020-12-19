class DateHelper {
  static String secondsToHoursMinutesSeconds(int seconds) {
    final hour = seconds ~/ 3600;
    final minute = (seconds % 3600) ~/ 60;
    final second = (seconds % 3600) % 60;
    final hourUpdate = hour < 10 ? '0$hour' : '$hour';
    final minuteUpdate = minute < 10 ? '0$minute' : '$minute';
    final secondUpdate = second < 10 ? '0$second' : '$second';
    if (hour <= 0) {
      return minuteUpdate + ' : ' + secondUpdate;
    }
    return hourUpdate + ' : ' + minuteUpdate + ' : ' + secondUpdate;
  }
}
