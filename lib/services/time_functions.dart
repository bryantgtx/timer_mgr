class TimeFunctions {
  // Seconds are in interesting concept.  Hard to have a timer without counting seconds, but
  // equally hard to have a timecard entry that counts seconds.

  // this is used to format the timer display, so includes seconds.
  static String timeFormatFromSeconds(int totalSeconds) {
    var hours = (totalSeconds / 3600).floor();
    var minutes = ((totalSeconds / 60) % 60).floor();
    var minutesStr = minutes
        .toString()
        .padLeft(2, '0');
    int seconds = (totalSeconds % 60).floor();
    var secondsStr = seconds.toString().padLeft(2, '0');
    return hours > 0 ? '${hours.toString()}:$minutesStr:$secondsStr' : '$minutesStr:$secondsStr';
  }

  // this is used to format the entry display, so it doesn't
  static String timeFormatFromHours(double totalHours) {
    var hours = totalHours.floor();
    var hoursFraction = totalHours - hours;
    var minutesStr = (hoursFraction * 60)
        .toInt()
        .toString()
        .padLeft(2, '0');

    return hours > 0 ? '${hours.toString()}:$minutesStr' : '0:$minutesStr';
  }

  static int parseSeconds(String duration) {
    int hours = 0;
    int minutes = 0;
    List<String> parts = duration.split(':');
    if (parts.length > 2 && parts[parts.length - 2].isNotEmpty) {
      hours = int.parse(parts[parts.length - 2]);
    }
    if (parts.length > 1) {
      minutes = int.parse(parts[parts.length - 1]);
    }
    return Duration(hours: hours, minutes: minutes,).inSeconds;
  }

}