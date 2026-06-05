import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/allergies/domain/entities/allergy.dart';
import 'package:orionhealth_health/features/allergies/domain/services/allergy_service.dart';
import 'package:orionhealth_health/features/medications/domain/entities/medication.dart';

void main() {
  late AllergyService allergyService;

  setUp(() {
    allergyService = AllergyService();
  });

  group('AllergyService', () {
    group('checkInteraction', () {
      final medication = Medication(
        name: 'Amoxicillin Capsule',
        startDate: DateTime.now(),
        notes: 'Take with food. Contains penicillin derivatives.',
      );

      test('should return true when medication name contains allergen', () {
        final allergy = Allergy(allergen: 'Amoxicillin');
        expect(allergyService.checkInteraction(allergy, medication), isTrue);
      });

      test('should return true when medication name contains allergen (case insensitive)', () {
        final allergy = Allergy(allergen: 'amoxicillin');
        expect(allergyService.checkInteraction(allergy, medication), isTrue);
      });

      test('should return true when medication notes contain allergen', () {
        final allergy = Allergy(allergen: 'penicillin');
        expect(allergyService.checkInteraction(allergy, medication), isTrue);
      });

      test('should return false when no interaction is found', () {
        final allergy = Allergy(allergen: 'Aspirin');
        expect(allergyService.checkInteraction(allergy, medication), isFalse);
      });

      test('should return false if allergy is invalid', () {
        final allergy = Allergy(allergen: '');
        expect(allergyService.checkInteraction(allergy, medication), isFalse);
      });
    });

    group('getSeverityLevel', () {
      test('should return 1 for mild', () {
        expect(allergyService.getSeverityLevel(AllergySeverity.mild), equals(1));
      });

      test('should return 2 for moderate', () {
        expect(allergyService.getSeverityLevel(AllergySeverity.moderate), equals(2));
      });

      test('should return 3 for severe', () {
        expect(allergyService.getSeverityLevel(AllergySeverity.severe), equals(3));
      });
    });
  });
}
