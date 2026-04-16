import 'package:flutter_test/flutter_test.dart';
import 'package:medical_standards/medical_standards.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LoincCode', () {
    test('findByCode returns correct code', () async {
      final code = await LoincCode.findByCode('2345-7');
      expect(code, isNotNull);
      expect(code!.code, equals('2345-7'));
    });

    test('findByCode returns null for invalid code', () async {
      final code = await LoincCode.findByCode('INVALID');
      expect(code, isNull);
    });

    test('findByCode finds glucose', () async {
      final glucose = await LoincCode.findByCode('2345-7');
      expect(glucose, isNotNull);
      expect(glucose!.component.toLowerCase(), contains('glucose'));
    });

    test('findByCode finds hemoglobin', () async {
      final hemoglobin = await LoincCode.findByCode('718-7');
      expect(hemoglobin, isNotNull);
      expect(hemoglobin!.component.toLowerCase(), contains('hemoglobin'));
    });

    test('props for Equatable equality', () async {
      final code1 = await LoincCode.findByCode('2345-7');
      final code2 = await LoincCode.findByCode('2345-7');
      expect(code1, equals(code2));
    });
  });

  group('LoincCommonLabs', () {
    test('findByCode returns correct lab', () async {
      final lab = await LoincCommonLabs.findByCode('4548-4');
      expect(lab, isNotNull);
      expect(lab!.code, equals('4548-4'));
      expect(lab.component.toLowerCase(), contains('hba1c'));
    });

    test('findByCode returns null for invalid code', () async {
      final lab = await LoincCommonLabs.findByCode('99999-9');
      expect(lab, isNull);
    });

    test('all returns non-empty list', () async {
      expect(await LoincCommonLabs.all, isNotEmpty);
    });
  });
}
