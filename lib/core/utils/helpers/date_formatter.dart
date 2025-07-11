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

  //  format date for backend
  String formatDateForBackend(String ddMMyyyy) {
  try {
    final parsed = DateFormat('dd/MM/yyyy').parse(ddMMyyyy);
    return DateFormat('yyyy-MM-dd').format(parsed);
  } catch (e) {
    return '';
  }
}

}
