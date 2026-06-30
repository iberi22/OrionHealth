import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/core/medical/pii_labels.dart';

void main() {
  group('normalizeLabel', () {
    test('normalizes basic labels', () {
      expect(normalizeLabel('person'), equals(person));
      expect(normalizeLabel('email'), equals(email));
      expect(normalizeLabel('PHONE_NUMBER'), equals(phone));
    });

    test('normalizes snake_case labels', () {
      expect(normalizeLabel('first_name'), equals(firstName));
      expect(normalizeLabel('date_of_birth'), equals(dateOfBirth));
    });

    test('normalizes UPPERCASE no-separator labels', () {
      expect(normalizeLabel('FIRSTNAME'), equals(firstName));
      expect(normalizeLabel('DATEOFBIRTH'), equals(dateOfBirth));
    });

    test('normalizes BIOES-tagged labels', () {
      expect(normalizeLabel('B-person'), equals(person));
      expect(normalizeLabel('I-email'), equals(email));
      expect(normalizeLabel('E-ADDRESS'), equals(streetAddress));
      expect(normalizeLabel('S-phone'), equals(phone));
    });

    test('normalizes mixed case with separators', () {
      expect(normalizeLabel('First-Name'), equals(firstName));
      expect(normalizeLabel('First Name'), equals(firstName));
      expect(normalizeLabel('  Phone Number  '), equals(phone));
    });

    test('normalizes medical specific labels', () {
      expect(normalizeLabel('patient_id'), equals(patientId));
      expect(normalizeLabel('DRUGNAME'), equals(drugName));
      expect(normalizeLabel('diag_code'), equals(diagnosisCode));
    });

    test('returns other for unknown labels', () {
      expect(normalizeLabel('UNKNOWN_ENTITY_TYPE'), equals(other));
      expect(normalizeLabel(''), equals(other));
    });

    test('handles canonical labels directly', () {
      expect(normalizeLabel('creditCard'), equals(creditCard));
      expect(normalizeLabel('medicalRecordNumber'), equals(medicalRecordNumber));
    });
  });

  group('piiEntityMeta', () {
    test('contains expected metadata for person', () {
      final meta = piiEntityMeta[person];
      expect(meta, isNotNull);
      expect(meta!['category'], equals('PII'));
      expect(meta['color'], equals('blue'));
    });

    test('contains expected metadata for medicalRecordNumber', () {
      final meta = piiEntityMeta[medicalRecordNumber];
      expect(meta, isNotNull);
      expect(meta!['category'], equals('PHI'));
      expect(meta['color'], equals('purple'));
    });

    test('contains expected metadata for drugName', () {
      final meta = piiEntityMeta[drugName];
      expect(meta, isNotNull);
      expect(meta!['category'], equals('MEDICAL'));
      expect(meta['color'], equals('purple'));
    });
  });
}
