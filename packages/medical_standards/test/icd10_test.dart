import 'package:flutter_test/flutter_test.dart';
import 'package:medical_standards/medical_standards.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Icd10Code', () {
    test('findByCode returns correct code', () async {
      final code = await Icd10Code.findByCode('E11');
      expect(code, isNotNull);
      expect(code!.code, equals('E11'));
      expect(code.displayName, contains('Type 2 diabetes'));
    });

    test('findByCode returns null for invalid code', () async {
      final code = await Icd10Code.findByCode('INVALID');
      expect(code, isNull);
    });

    test('findByCode is case insensitive', () async {
      final code1 = await Icd10Code.findByCode('E11');
      final code2 = await Icd10Code.findByCode('e11');
      expect(code1, isNotNull);
      expect(code2, isNotNull);
    });

    test('findByCategory returns codes for valid category', () async {
      final codes = await Icd10Code.findByCategory('Endocrine');
      expect(codes, isNotEmpty);
      expect(codes.every((c) => c.category == 'Endocrine'), isTrue);
    });

    test('findByCategory returns empty for invalid category', () async {
      final codes = await Icd10Code.findByCategory('XYZ');
      expect(codes, isEmpty);
    });

    test('props for Equatable equality', () async {
      final code1 = await Icd10Code.findByCode('E11');
      final code2 = await Icd10Code.findByCode('E11');
      expect(code1, equals(code2));
      expect(code1?.props, equals(code2?.props));
    });
  });

  group('Icd10ChronicConditions', () {
    test('all returns non-empty list', () async {
      expect(await Icd10ChronicConditions.all, isNotEmpty);
    });

    test('all contains common chronic conditions', () async {
      final codes = await Icd10ChronicConditions.all;
      final codesStr = codes.map((c) => c.code).toList();
      expect(codesStr, contains('E11'));
      // Note: full_icd10.json only contains a subset of codes
      expect(codesStr, contains('E10'));
    });

    test('findByCode returns correct code', () async {
      final code = await Icd10ChronicConditions.findByCode('E11');
      expect(code, isNotNull);
      expect(code!.code, equals('E11'));
    });
  });
}
