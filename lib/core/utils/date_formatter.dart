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

  static String? formatDateNullable(DateTime? date) {
    if (date == null) return null;
    return formatDate(date);
  }

  static bool isDateInRange(DateTime date, DateTime start, DateTime end) {
    return date.isAfter(start.subtract(const Duration(days: 1))) && 
           date.isBefore(end.add(const Duration(days: 1)));
  }

  static DateTime getStartOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static DateTime getEndOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  static String getFinancialYear(DateTime date) {
    final year = date.month >= 4 ? date.year : date.year - 1;
    return '$year-${(year + 1).toString().substring(2)}';
  }
}
