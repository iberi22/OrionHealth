import 'package:test/test.dart';
import 'package:medical_standards/medical_standards.dart';

void main() {
  group('MedicationReference', () {
    test('catalog findByCode returns correct medication', () {
      final med = MedicationCatalog.findByCode('6809'); // Metformin in lib
      expect(med, isNotNull);
      expect(med!.code, equals('6809'));
    });

    test('catalog findByCode returns null for invalid code', () {
      final med = MedicationCatalog.findByCode('INVALID');
      expect(med, isNull);
    });

    test('catalog findByCode finds Metformin', () {
      final metformin = MedicationCatalog.findByCode('6809');
      expect(metformin, isNotNull);
      expect(metformin!.displayName.toLowerCase(), contains('metformin'));
    });

    test('props for Equatable equality', () {
      final m1 = MedicationCatalog.findByCode('6809');
      final m2 = MedicationCatalog.findByCode('6809');
      expect(m1, equals(m2));
    });
  });

  group('MedicationCatalog', () {
    test('all returns non-empty list', () {
      expect(MedicationCatalog.all, isNotEmpty);
    });

    test('findByCode returns correct medication', () {
      final med = MedicationCatalog.findByCode('6809');
      expect(med, isNotNull);
      expect(med!.code, equals('6809'));
    });

    test('findByName returns correct medication', () {
      final med = MedicationCatalog.findByName('metformin');
      expect(med, isNotNull);
      expect(med!.displayName.toLowerCase(), contains('metformin'));
    });

    test('findByName is case insensitive', () {
      final med1 = MedicationCatalog.findByName('Metformin');
      final med2 = MedicationCatalog.findByName('metformin');
      expect(med1, isNotNull);
      expect(med2, isNotNull);
      expect(med1!.displayName, equals(med2!.displayName));
    });

    test('findByClass returns medications for valid class', () {
      final meds = MedicationCatalog.findByClass('Biguanide');
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
