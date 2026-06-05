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
    });
   group('AllergySeverity Enum', () {
      test('AllergySeverity should have correct values', () {
        expect(AllergySeverity.values.length, 3);
        expect(AllergySeverity.mild.index, 0);
        expect(AllergySeverity.moderate.index, 1);
        expect(AllergySeverity.severe.index, 2);
      });
    });
  });
}
