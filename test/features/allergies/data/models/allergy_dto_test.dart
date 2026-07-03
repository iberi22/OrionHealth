import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/allergies/data/models/allergy_dto.dart';
import 'package:orionhealth_health/features/allergies/domain/entities/allergy.dart';

void main() {
  group('AllergyDto', () {
    const tAllergyDto = AllergyDto(
      id: 1,
      allergen: 'Peanuts',
      severity: 'severe',
      notes: 'Anaphylaxis',
    );

    final tAllergy = Allergy(
      id: 1,
      allergen: 'Peanuts',
      severity: AllergySeverity.severe,
      notes: 'Anaphylaxis',
    );

    test('fromEntity should return a valid DTO', () {
      final result = AllergyDto.fromEntity(tAllergy);
      expect(result.id, tAllergy.id);
      expect(result.allergen, tAllergy.allergen);
      expect(result.severity, tAllergy.severity.name);
      expect(result.notes, tAllergy.notes);
    });

    test('toEntity should return a valid entity', () {
      final result = tAllergyDto.toEntity();
      expect(result.id, tAllergyDto.id);
      expect(result.allergen, tAllergyDto.allergen);
      expect(result.severity.name, tAllergyDto.severity);
      expect(result.notes, tAllergyDto.notes);
    });

    test('toJson should return a valid JSON map', () {
      final result = tAllergyDto.toJson();
      final expectedMap = {
        'id': 1,
        'allergen': 'Peanuts',
        'severity': 'severe',
        'notes': 'Anaphylaxis',
      };
      expect(result, expectedMap);
    });

    test('fromJson should return a valid DTO', () {
      final jsonMap = {
        'id': 1,
        'allergen': 'Peanuts',
        'severity': 'severe',
        'notes': 'Anaphylaxis',
      };
      final result = AllergyDto.fromJson(jsonMap);
      expect(result.id, tAllergyDto.id);
      expect(result.allergen, tAllergyDto.allergen);
      expect(result.severity, tAllergyDto.severity);
      expect(result.notes, tAllergyDto.notes);
    });

    test('toEntity should handle unknown severity by defaulting to mild', () {
      const dto = AllergyDto(severity: 'unknown');
      final result = dto.toEntity();
      expect(result.severity, AllergySeverity.mild);
    });
  });
}
