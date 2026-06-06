import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/allergies/domain/entities/allergy.dart';
import 'package:isar/isar.dart';

void main() {
  group('Allergy Entity', () {
    test('should create an Allergy with default values', () {
      final allergy = Allergy();

      expect(allergy.id, equals(Isar.autoIncrement));
      expect(allergy.allergen, isNull);
      expect(allergy.severity, equals(AllergySeverity.mild));
      expect(allergy.notes, isNull);
    });

    test('should create an Allergy with provided values', () {
      final allergy = Allergy(
        id: 1,
        allergen: 'Penicillin',
        severity: AllergySeverity.severe,
        notes: 'Anaphylaxis risk',
      );

      expect(allergy.id, equals(1));
      expect(allergy.allergen, equals('Penicillin'));
      expect(allergy.severity, equals(AllergySeverity.severe));
      expect(allergy.notes, equals('Anaphylaxis risk'));
    });

    group('isValid', () {
      test('should return false if allergen is null', () {
        final allergy = Allergy(allergen: null);
        expect(allergy.isValid, isFalse);
      });

      test('should return false if allergen is empty', () {
        final allergy = Allergy(allergen: '');
        expect(allergy.isValid, isFalse);
      });

      test('should return false if allergen is only whitespace', () {
        final allergy = Allergy(allergen: '   ');
        expect(allergy.isValid, isFalse);
      });

      test('should return true if allergen is provided', () {
        final allergy = Allergy(allergen: 'Peanuts');
        expect(allergy.isValid, isTrue);
      });

      test('should return true for allergen with special characters', () {
        final allergy = Allergy(allergen: 'Pollen-123!');
        expect(allergy.isValid, isTrue);
      });

      test('should return true for very long allergen name', () {
        final allergy = Allergy(allergen: 'a' * 1000);
        expect(allergy.isValid, isTrue);
      });

      test('should return false for allergen with only tabs and newlines', () {
        final allergy = Allergy(allergen: '\t\n  ');
        expect(allergy.isValid, isFalse);
      });
    });

    group('AllergySeverity Enum', () {
      test('AllergySeverity should have correct values', () {
        expect(AllergySeverity.values.length, 3);
        expect(AllergySeverity.mild.index, 0);
        expect(AllergySeverity.moderate.index, 1);
        expect(AllergySeverity.severe.index, 2);
      });
    });

    test('should support equality by reference (default Isar behavior)', () {
      final allergy1 = Allergy(id: 1, allergen: 'Dust');
      final allergy2 = Allergy(id: 1, allergen: 'Dust');

      // Not using Equatable, so they should not be equal by value
      expect(allergy1, isNot(equals(allergy2)));
    });
  });
}
