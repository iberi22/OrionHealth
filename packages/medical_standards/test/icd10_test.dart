import 'package:flutter_test/flutter_test.dart';
import 'package:medical_standards/medical_standards.dart';

void main() {
  group('Icd10Code', () {
    test('findByCode returns correct code', () {
      final code = Icd10Code.findByCode('E11');
      expect(code, isNotNull);
      expect(code!.code, equals('E11'));
      expect(code.description, contains('diabetes'));
    });

    test('findByCode returns null for invalid code', () {
      final code = Icd10Code.findByCode('INVALID');
      expect(code, isNull);
    });

    test('findByCode is case insensitive', () {
      final code1 = Icd10Code.findByCode('E11');
      final code2 = Icd10Code.findByCode('e11');
      final code3 = Icd10Code.findByCode('E11.9');
      expect(code1, isNotNull);
      expect(code2, isNotNull);
      expect(code3, isNotNull);
    });

    test('findByCategory returns codes for valid category', () {
      final codes = Icd10Code.findByCategory('E');
      expect(codes, isNotEmpty);
      expect(codes.every((c) => c.code.startsWith('E')), isTrue);
    });

    test('findByCategory returns empty for invalid category', () {
      final codes = Icd10Code.findByCategory('XYZ');
      expect(codes, isEmpty);
    });

    test('isChronic returns true for chronic conditions', () {
      final diabetes = Icd10Code.findByCode('E11');
      final hypertension = Icd10Code.findByCode('I10');
      final strep = Icd10Code.findByCode('J06.9');
      expect(diabetes?.isChronic, isTrue);
      expect(hypertension?.isChronic, isTrue);
      expect(strep?.isChronic, isFalse);
    });

    test('props for Equatable equality', () {
      final code1 = Icd10Code.findByCode('E11');
      final code2 = Icd10Code.findByCode('E11');
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
      expect(codesStr, contains('J45'));
    });

    test('findByCode returns correct code', () {
      final code = Icd10ChronicConditions.findByCode('E11');
      expect(code, isNotNull);
      expect(code!.code, equals('E11'));
    });
  });
}
