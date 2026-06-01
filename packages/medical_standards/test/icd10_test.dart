import 'package:test/test.dart';
import 'package:medical_standards/medical_standards.dart';

void main() {
  group('Icd10Code', () {
    test('findByCode returns correct code', () {
      final code = Icd10ChronicConditions.findByCode('E11');
      expect(code, isNotNull);
      expect(code!.code, equals('E11'));
      expect(code.description, isNotNull);
    });

    test('findByCode returns null for invalid code', () {
      final code = Icd10ChronicConditions.findByCode('INVALID');
      expect(code, isNull);
    });

    test('findBySynonym returns matching code', () {
      final code = Icd10ChronicConditions.findBySynonym('DM2');
      expect(code, isNotNull);
      expect(code!.code, equals('E11'));
    });

    test('findByCategory returns codes for valid category', () {
      final codes = Icd10ChronicConditions.findByCategory('Endocrine');
      expect(codes, isNotEmpty);
      expect(codes.every((c) => c.code.startsWith('E')), isTrue);
    });

    test('findByCategory returns empty for invalid category', () {
      final codes = Icd10ChronicConditions.findByCategory('XYZ');
      expect(codes, isEmpty);
    });

    test('props for Equatable equality', () {
      final code1 = Icd10ChronicConditions.findByCode('E11');
      final code2 = Icd10ChronicConditions.findByCode('E11');
      expect(code1, equals(code2));
      expect(code1?.props, equals(code2?.props));
    });
  });

  group('Icd10ChronicConditions', () {
    test('all returns non-empty list', () {
      expect(Icd10ChronicConditions.all, isNotEmpty);
    });

    test('all contains common chronic conditions', () {
      final codes = Icd10ChronicConditions.all;
      final codesStr = codes.map((c) => c.code).toList();
      expect(codesStr, contains('E11'));
      expect(codesStr, contains('I10'));
    });

    test('findByCode returns correct code', () {
      final code = Icd10ChronicConditions.findByCode('E11');
      expect(code, isNotNull);
      expect(code!.code, equals('E11'));
    });
  });
}
