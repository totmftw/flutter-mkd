// lib/core/utils/date_formatter.dart
import 'package:intl/intl.dart';

class DateFormatter {
  static String formatDate(DateTime date) {
    return DateFormat('dd-MM-yyyy').format(date);
  }

  static DateTime? parseDate(String date) {
    try {
      final parts = date.split('-');
      if (parts.length != 3) return null;
      
      return DateTime(
        int.parse(parts[2]), // year
        int.parse(parts[1]), // month
        int.parse(parts[0]), // day
      );
    } catch (e) {
      return null;
    }
  }

  static bool isValidDate(String date) {
    return parseDate(date) != null;
  }
}
