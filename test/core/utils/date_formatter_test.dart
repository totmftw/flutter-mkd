import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_mkd/core/utils/date_formatter.dart';

void main() {
  group('DateFormatter Tests', () {
    test('formatDate should return correct Indian format', () {
      final date = DateTime(2024, 1, 15);
      expect(DateFormatter.formatDate(date), equals('15-01-2024'));
    });

    test('parseDate should correctly parse valid date string', () {
      const dateStr = '15-01-2024';
      final parsed = DateFormatter.parseDate(dateStr);
      expect(parsed, isNotNull);
      expect(parsed?.day, equals(15));
      expect(parsed?.month, equals(1));
      expect(parsed?.year, equals(2024));
    });

    test('parseDate should return null for invalid date string', () {
      expect(DateFormatter.parseDate('15/01/2024'), isNull);
      expect(DateFormatter.parseDate('2024-01-15'), isNull);
      expect(DateFormatter.parseDate('invalid'), isNull);
    });

    test('isValidDate should return correct boolean', () {
      expect(DateFormatter.isValidDate('15-01-2024'), isTrue);
      expect(DateFormatter.isValidDate('15/01/2024'), isFalse);
      expect(DateFormatter.isValidDate('invalid'), isFalse);
    });

    test('formatDateNullable should handle null dates', () {
      expect(DateFormatter.formatDateNullable(null), isNull);
      expect(
        DateFormatter.formatDateNullable(DateTime(2024, 1, 15)), 
        equals('15-01-2024')
      );
    });

    test('isDateInRange should correctly check date ranges', () {
      final start = DateTime(2024, 1, 1);
      final end = DateTime(2024, 1, 31);
      final date = DateTime(2024, 1, 15);
      final outOfRange = DateTime(2024, 2, 1);

      expect(DateFormatter.isDateInRange(date, start, end), isTrue);
      expect(DateFormatter.isDateInRange(outOfRange, start, end), isFalse);
    });

    test('getFinancialYear should return correct format', () {
      expect(
        DateFormatter.getFinancialYear(DateTime(2024, 4, 1)), 
        equals('2024-25')
      );
      expect(
        DateFormatter.getFinancialYear(DateTime(2024, 3, 31)), 
        equals('2023-24')
      );
    });
  });
}
