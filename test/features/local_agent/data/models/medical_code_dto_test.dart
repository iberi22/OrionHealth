import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/local_agent/data/models/medical_code_dto.dart';
import 'package:orionhealth_health/features/local_agent/domain/entities/medical_code.dart';

void main() {
  group('MedicalCodeDto', () {
    test('constructor assigns all fields correctly', () {
      const dto = MedicalCodeDto(
        code: 'E11',
        displayName: 'Type 2 diabetes mellitus',
        standard: 'ICD-10',
        category: 'Endocrine',
        searchTerms: ['diabetes', 'tipo 2', 'azúcar'],
      );

      expect(dto.code, 'E11');
      expect(dto.displayName, 'Type 2 diabetes mellitus');
      expect(dto.standard, 'ICD-10');
      expect(dto.category, 'Endocrine');
      expect(dto.searchTerms, ['diabetes', 'tipo 2', 'azúcar']);
    });

    test('constructor uses defaults for optional fields', () {
      const dto = MedicalCodeDto(
        code: 'I10',
        displayName: 'Essential hypertension',
        standard: 'ICD-10',
      );

      expect(dto.category, '');
      expect(dto.searchTerms, []);
    });

    group('fromEntity', () {
      test('creates DTO from MedicalCode entity', () {
        final entity = MedicalCode(
          code: 'J45.0',
          displayName: 'Asthma',
          category: 'Respiratory',
          standard: 'ICD-10',
          searchTerms: ['asma', 'wheezing', 'dificultad respirar'],
        );

        final dto = MedicalCodeDto.fromEntity(entity);

        expect(dto.code, 'J45.0');
        expect(dto.displayName, 'Asthma');
        expect(dto.standard, 'ICD-10');
        expect(dto.category, 'Respiratory');
        expect(dto.searchTerms, ['asma', 'wheezing', 'dificultad respirar']);
      });

      test('fromEntity handles entity with empty optional fields', () {
        final entity = MedicalCode(
          code: 'Z00.0',
          displayName: 'General examination',
          category: '',
          standard: 'ICD-10',
        );

        final dto = MedicalCodeDto.fromEntity(entity);

        expect(dto.code, 'Z00.0');
        expect(dto.category, '');
        expect(dto.searchTerms, []);
      });
    });

    group('toJson', () {
      test('serializes correctly to JSON map', () {
        const dto = MedicalCodeDto(
          code: 'E78.0',
          displayName: 'Hypercholesterolemia',
          standard: 'ICD-10',
          category: 'Metabolic',
          searchTerms: ['colesterol', 'LDL'],
        );

        final json = dto.toJson();

        expect(json['code'], 'E78.0');
        expect(json['displayName'], 'Hypercholesterolemia');
        expect(json['standard'], 'ICD-10');
        expect(json['category'], 'Metabolic');
        expect(json['searchTerms'], ['colesterol', 'LDL']);
        expect(json.keys, containsAll(['code', 'displayName', 'standard', 'category', 'searchTerms']));
      });

      test('toJson handles empty optional fields', () {
        const dto = MedicalCodeDto(
          code: 'R10',
          displayName: 'Abdominal pain',
          standard: 'ICD-10',
        );

        final json = dto.toJson();

        expect(json['category'], '');
        expect(json['searchTerms'], []);
      });
    });

    test('round-trip from entity to json preserves data', () {
      final entity = MedicalCode(
        code: 'N18.3',
        displayName: 'Chronic kidney disease stage 3',
        category: 'Renal',
        standard: 'ICD-10',
        searchTerms: ['insuficiencia renal', 'CKD'],
      );

      final dto = MedicalCodeDto.fromEntity(entity);
      final json = dto.toJson();
      final restored = MedicalCode.fromJson(json, 'ICD-10');

      expect(restored.code, 'N18.3');
      expect(restored.displayName, 'Chronic kidney disease stage 3');
      expect(restored.category, '');
      expect(restored.searchTerms, ['insuficiencia renal', 'CKD']);
    });
  });
}
