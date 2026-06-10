import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/allergies/domain/entities/allergy.dart';
import 'package:orionhealth_health/features/allergies/domain/services/allergy_service.dart';
import 'package:orionhealth_health/features/medications/domain/entities/medication.dart';

class MockMedication extends Mock implements Medication {}

void main() {
  late AllergyService allergyService;
  late MockMedication mockMedication;

  setUp(() {
    allergyService = AllergyService();
    mockMedication = MockMedication();
  });

  group('AllergyService', () {
    group('checkInteraction', () {
      test('should return true when medication name contains allergen', () {
        final allergy = Allergy(allergen: 'Amoxicillin');
        when(() => mockMedication.name).thenReturn('Amoxicillin Capsule');
        when(() => mockMedication.notes).thenReturn(null);

        expect(allergyService.checkInteraction(allergy, mockMedication), isTrue);
      });

      test('should return true when medication name contains allergen (case insensitive)', () {
        final allergy = Allergy(allergen: 'amoxicillin');
        when(() => mockMedication.name).thenReturn('AMOXICILLIN CAPSULE');
        when(() => mockMedication.notes).thenReturn(null);

        expect(allergyService.checkInteraction(allergy, mockMedication), isTrue);
      });

      test('should return true when medication notes contain allergen', () {
        final allergy = Allergy(allergen: 'penicillin');
        when(() => mockMedication.name).thenReturn('Some Med');
        when(() => mockMedication.notes).thenReturn('Contains penicillin derivatives.');

        expect(allergyService.checkInteraction(allergy, mockMedication), isTrue);
      });

      test('should return false when no interaction is found', () {
        final allergy = Allergy(allergen: 'Aspirin');
        when(() => mockMedication.name).thenReturn('Amoxicillin');
        when(() => mockMedication.notes).thenReturn('Take with food');

        expect(allergyService.checkInteraction(allergy, mockMedication), isFalse);
      });

      test('should return false if allergy is invalid', () {
        final allergy = Allergy(allergen: '');
        expect(allergyService.checkInteraction(allergy, mockMedication), isFalse);
      });

      test('should return true for partial matches within words', () {
        final allergy = Allergy(allergen: 'Sulfa');
        when(() => mockMedication.name).thenReturn('Sulfamethoxazole');
        when(() => mockMedication.notes).thenReturn(null);

        expect(allergyService.checkInteraction(allergy, mockMedication), isTrue);
      });

      test('should handle allergen with leading/trailing whitespace', () {
        final allergy = Allergy(allergen: '  penicillin  ');
        when(() => mockMedication.name).thenReturn('Some Med');
        when(() => mockMedication.notes).thenReturn('Contains penicillin');

        expect(allergyService.checkInteraction(allergy, mockMedication), isTrue);
      });

      test('should return false for null allergen', () {
        final allergy = Allergy(allergen: null);
        when(() => mockMedication.name).thenReturn('Amoxicillin');
        expect(allergyService.checkInteraction(allergy, mockMedication), isFalse);
      });

      test('should return false for empty allergen', () {
        final allergy = Allergy(allergen: '');
        when(() => mockMedication.name).thenReturn('Amoxicillin');
        expect(allergyService.checkInteraction(allergy, mockMedication), isFalse);
      });

      test('should return false for only whitespace allergen', () {
        final allergy = Allergy(allergen: '   ');
        when(() => mockMedication.name).thenReturn('Amoxicillin');
        expect(allergyService.checkInteraction(allergy, mockMedication), isFalse);
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
