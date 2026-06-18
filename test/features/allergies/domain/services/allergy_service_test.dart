import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/allergies/domain/entities/allergy.dart';
import 'package:orionhealth_health/features/allergies/domain/services/allergy_service.dart';
import 'package:orionhealth_health/features/medications/domain/entities/medication.dart';

void main() {
  group('AllergyService', () {
    late AllergyService service;

    setUp(() {
      service = AllergyService();
    });

    group('checkInteraction', () {
      test('returns true when medication name contains allergen', () {
        final allergy = Allergy(
          id: 1,
          name: 'Penicilina',
          severity: AllergySeverity.severe,
          isValid: true,
        );
        final medication = Medication(
          id: 1,
          name: 'Amoxicilina',
          startDate: DateTime.now(),
          notes: '',
        );
        expect(service.checkInteraction(allergy, medication), isTrue);
      });

      test('returns true when medication notes contain allergen', () {
        final allergy = Allergy(
          id: 1,
          name: 'Penicilina',
          severity: AllergySeverity.moderate,
          isValid: true,
        );
        final medication = Medication(
          id: 1,
          name: 'Ibuprofeno',
          startDate: DateTime.now(),
          notes: 'No usar si alergia a penicilina',
        );
        expect(service.checkInteraction(allergy, medication), isTrue);
      });

      test('returns false when no interaction', () {
        final allergy = Allergy(
          id: 1,
          name: 'Penicilina',
          severity: AllergySeverity.mild,
          isValid: true,
        );
        final medication = Medication(
          id: 1,
          name: 'Ibuprofeno',
          startDate: DateTime.now(),
        );
        expect(service.checkInteraction(allergy, medication), isFalse);
      });

      test('returns false when allergy is not valid', () {
        final allergy = Allergy(
          id: 1,
          name: 'Penicilina',
          severity: AllergySeverity.mild,
          isValid: false,
        );
        final medication = Medication(
          id: 1,
          name: 'Amoxicilina',
          startDate: DateTime.now(),
        );
        expect(service.checkInteraction(allergy, medication), isFalse);
      });

      test('is case insensitive', () {
        final allergy = Allergy(
          id: 1,
          name: 'PENICILINA',
          severity: AllergySeverity.mild,
          isValid: true,
        );
        final medication = Medication(
          id: 1,
          name: 'amoxicilina',
          startDate: DateTime.now(),
        );
        expect(service.checkInteraction(allergy, medication), isTrue);
      });
    });

    group('getSeverityLevel', () {
      test('mild returns 1', () {
        expect(service.getSeverityLevel(AllergySeverity.mild), 1);
      });

      test('moderate returns 2', () {
        expect(service.getSeverityLevel(AllergySeverity.moderate), 2);
      });

      test('severe returns 3', () {
        expect(service.getSeverityLevel(AllergySeverity.severe), 3);
      });
    });
  });
}
