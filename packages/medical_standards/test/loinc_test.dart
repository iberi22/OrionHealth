import 'package:test/test.dart';
import 'package:medical_standards/medical_standards.dart';

void main() {
  group('LoincCode', () {
    test('findByCode returns correct code', () {
      final code = LoincCommonLabs.findByCode('2339-0');
      expect(code, isNotNull);
      expect(code!.code, equals('2339-0'));
    });

    test('findByCode returns null for invalid code', () {
      final code = LoincCommonLabs.findByCode('INVALID');
      expect(code, isNull);
    });

    test('findByComponent finds glucose', () {
      final glucose = LoincCommonLabs.findByComponent('Glucose');
      expect(glucose, isNotNull);
      expect(glucose!.component.toLowerCase(), contains('glucose'));
    });

    test('findByCode finds hemoglobin', () {
      final hemoglobin = LoincCommonLabs.findByCode('718-7');
      expect(hemoglobin, isNotNull);
      expect(hemoglobin!.component.toLowerCase(), contains('hemoglobin'));
    });

    test('props for Equatable equality', () {
      final code1 = LoincCommonLabs.findByCode('2339-0');
      final code2 = LoincCommonLabs.findByCode('2339-0');
      expect(code1, equals(code2));
    });
  });

  group('LoincCommonLabs', () {
    test('findByCode returns correct lab', () {
      final lab = LoincCommonLabs.findByCode('4548-4');
      expect(lab, isNotNull);
      expect(lab!.code, equals('4548-4'));
      expect(lab.component.toLowerCase(), contains('hemoglobin'));
    });

    test('findByCode returns null for invalid code', () {
      final lab = LoincCommonLabs.findByCode('99999-9');
      expect(lab, isNull);
    });

    test('findByCode finds HbA1c', () {
      final hba1c = LoincCommonLabs.findByCode('4548-4');
      expect(hba1c, isNotNull);
      expect(hba1c!.component, equals('Hemoglobin A1c'));
    });

    test('findByCode finds TSH', () {
      final tsh = LoincCommonLabs.findByCode('3016-3');
      expect(tsh, isNotNull);
      expect(tsh!.component.toLowerCase(), contains('thyrotropin'));
    });

    test('all returns non-empty list', () {
      expect(LoincCommonLabs.all, isNotEmpty);
    });

    test('normal range is available for common labs', () {
      final glucose = LoincCommonLabs.findByCode('2345-7');
      expect(glucose?.normalRange, isNotNull);
      expect(glucose?.normalRange, isNotEmpty);
    });
  });
}
