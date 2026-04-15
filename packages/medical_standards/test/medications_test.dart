import 'package:flutter_test/flutter_test.dart';
import 'package:medical_standards/medical_standards.dart';

void main() {
  group('MedicationReference', () {
    test('findByRxNormCode returns correct medication', () {
      final med = MedicationReference.findByRxNormCode('311354');
      expect(med, isNotNull);
      expect(med!.rxNormCode, equals('311354'));
    });

    test('findByRxNormCode returns null for invalid code', () {
      final med = MedicationReference.findByRxNormCode('INVALID');
      expect(med, isNull);
    });

    test('findByRxNormCode finds Metformin', () {
      final metformin = MedicationReference.findByRxNormCode('311354');
      expect(metformin, isNotNull);
      expect(metformin!.name.toLowerCase(), contains('metformin'));
    });

    test('props for Equatable equality', () {
      final m1 = MedicationReference.findByRxNormCode('311354');
      final m2 = MedicationReference.findByRxNormCode('311354');
      expect(m1, equals(m2));
    });
  });

  group('MedicationCatalog', () {
    test('all returns non-empty list', () {
      expect(MedicationCatalog.all, isNotEmpty);
    });

    test('findByRxNormCode returns correct medication', () {
      final med = MedicationCatalog.findByRxNormCode('311354');
      expect(med, isNotNull);
      expect(med!.rxNormCode, equals('311354'));
    });

    test('findByName returns correct medication', () {
      final meds = MedicationCatalog.findByName('metformin');
      expect(meds, isNotEmpty);
      expect(meds.first.name.toLowerCase(), contains('metformin'));
    });

    test('findByName is case insensitive', () {
      final meds1 = MedicationCatalog.findByName('Metformin');
      final meds2 = MedicationCatalog.findByName('metformin');
      expect(meds1, isNotEmpty);
      expect(meds2, isNotEmpty);
      expect(meds1.first.name, equals(meds2.first.name));
    });

    test('findByClass returns medications for valid class', () {
      final meds = MedicationCatalog.findByClass('biguanide');
      expect(meds, isNotEmpty);
    });

    test('findByClass returns empty for invalid class', () {
      final meds = MedicationCatalog.findByClass('invalidclass');
      expect(meds, isEmpty);
    });

    test('findByName returns empty for unknown name', () {
      final meds = MedicationCatalog.findByName('unknownmedication12345');
      expect(meds, isEmpty);
    });
  });
}
