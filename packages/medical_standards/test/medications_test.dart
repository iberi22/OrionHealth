import 'package:test/test.dart';
import 'package:medical_standards/medical_standards.dart';

void main() {
  group('MedicationReference', () {
    test('findByCode returns correct medication', () {
      final med = MedicationCatalog.findByCode('311354');
      expect(med, isNotNull);
      expect(med!.code, equals('311354'));
    });

    test('findByCode returns null for invalid code', () {
      final med = MedicationCatalog.findByCode('INVALID');
      expect(med, isNull);
    });

    test('findByName finds Metformin', () {
      final metformin = MedicationCatalog.findByName('Metformin');
      expect(metformin, isNotNull);
      expect(metformin!.displayName.toLowerCase(), contains('metformin'));
    });

    test('props for Equatable equality', () {
      final m1 = MedicationCatalog.findByCode('311354');
      final m2 = MedicationCatalog.findByCode('311354');
      expect(m1, equals(m2));
    });
  });

  group('MedicationCatalog', () {
    test('all returns non-empty list', () {
      expect(MedicationCatalog.all, isNotEmpty);
    });

    test('findByCode returns correct medication', () {
      final med = MedicationCatalog.findByCode('311354');
      expect(med, isNotNull);
      expect(med!.code, equals('311354'));
    });

    test('findByName returns correct medication', () {
      final med = MedicationCatalog.findByName('Metformin');
      expect(med, isNotNull);
      expect(med!.displayName.toLowerCase(), contains('metformin'));
    });

    test('findByName is case insensitive', () {
      final med1 = MedicationCatalog.findByName('Metformin');
      final med2 = MedicationCatalog.findByName('metformin');
      expect(med1, isNotNull);
      expect(med2, isNotNull);
      expect(med1!.code, equals(med2!.code));
    });

    test('findByClass returns medications for valid class', () {
      final meds = MedicationCatalog.findByClass('biguanide');
      expect(meds, isNotEmpty);
    });

    test('findByClass returns empty for invalid class', () {
      final meds = MedicationCatalog.findByClass('invalidclass');
      expect(meds, isEmpty);
    });

    test('findByName returns null for unknown name', () {
      final med = MedicationCatalog.findByName('unknownmedication12345');
      expect(med, isNull);
    });
  });
}
