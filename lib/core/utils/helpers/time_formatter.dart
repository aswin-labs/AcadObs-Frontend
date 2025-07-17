import 'package:intl/intl.dart';

class TimeFormatter {
  static String formatTime(DateTime dateTime) {
    final localTime = dateTime.toLocal();
    return DateFormat('hh:mm a').format(localTime);
  }

  static String formatTimeFromString(String dateTimeString) {
    final dateTime = DateTime.parse(dateTimeString).toLocal();
    return DateFormat('hh:mm a').format(dateTime);
  }
}
