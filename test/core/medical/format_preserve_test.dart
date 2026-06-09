import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/core/medical/format_preserve.dart';

void main() {
  group('extractDigitGroups', () {
    test('should extract digit groups from US phone', () {
      expect(extractDigitGroups('+1 (415) 555-1234'), [1, 3, 3, 4]);
    });

    test('should extract digit groups from French phone', () {
      expect(extractDigitGroups('+33 6 12 34 56 78'), [2, 1, 2, 2, 2, 2]);
    });

    test('should return empty list for text with no digits', () {
      expect(extractDigitGroups('hello world'), []);
    });
  });

  group('preservePhoneFormat', () {
    test('should keep non-digit chars, replace digits', () {
      final result = preservePhoneFormat('+1 (415) 555-1234');
      expect(result, matches(r'^\+\d \(\d{3}\) \d{3}-\d{4}$'));
      expect(result, isNot(equals('+1 (415) 555-1234')));
    });

    test('should work with simple digits', () {
      final result = preservePhoneFormat('555-1234');
      expect(result, matches(r'^\d{3}-\d{4}$'));
    });
  });

  group('preserveDateFormat', () {
    test('should use same separator slash by default', () {
      final result = preserveDateFormat('05/06/2020');
      expect(result, matches(r'^\d{2}/\d{2}/\d{4}$'));
    });

    test('should use dash separator when original uses dash', () {
      final result = preserveDateFormat('2020-12-31');
      expect(result, matches(r'^\d{4}-\d{2}-\d{2}$'));
    });

    test('should use day-first when specified', () {
      final result = preserveDateFormat('01/02/2020', dayFirst: true);
      expect(result, matches(r'^\d{2}/\d{2}/\d{4}$'));
    });
  });

  group('preserveEmailPattern', () {
    test('should keep domain, replace local part', () {
      final result = preserveEmailPattern('john@hospital.org', 'fake@test.com');
      expect(result, equals('fake@hospital.org'));
    });

    test('should return fake email verbatim when original has no @', () {
      expect(preserveEmailPattern('notanemail', 'test@test.com'), 'test@test.com');
    });
  });

  group('preserveIdPattern', () {
    test('should replace digits with random digits', () {
      final result = preserveIdPattern('ABC-123-XYZ');
      expect(result, matches(r'^[A-Z]{3}-\d{3}-[A-Z]{3}$'));
      expect(result, isNot(equals('ABC-123-XYZ')));
    });

    test('should preserve separators', () {
      final result = preserveIdPattern('12-34-56');
      expect(result, matches(r'^\d{2}-\d{2}-\d{2}$'));
    });
  });
}
