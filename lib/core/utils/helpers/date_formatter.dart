import 'package:intl/intl.dart';

class DateFormatter {
  // Function to format DateTime object to a specific string format
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd - MM - yyyy').format(dateTime);
  }

  // format date yyyy -mm-dd to dd -mm -yyyy
  static String formatDateString(String date) {
    final dateTime = DateTime.parse(date);
    return DateFormat('dd-MM-yyyy').format(dateTime);
  }
}
