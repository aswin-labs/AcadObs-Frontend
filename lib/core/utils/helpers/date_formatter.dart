import 'package:intl/intl.dart';

class DateFormatter {
  // Function to format DateTime object to a specific string format
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd - MM - yyyy').format(dateTime);
  }
}
