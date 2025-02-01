// test/core/utils/date_formatter_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:your_app_name/core/utils/date_formatter.dart';

void main() {
  group('DateFormatter', () {
    test('formatDate should return correct Indian format', () {
      final date = DateTime(2024, 1, 15);
      expect(DateFormatter.formatDate(date), equals('15-01-2024'));
    });

    test('parseDate should correctly parse valid date string', () {
      final dateStr = '15-01-2024';
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
  });
}
