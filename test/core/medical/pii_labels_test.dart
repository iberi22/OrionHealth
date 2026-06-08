import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/core/medical/pii_labels.dart';

void main() {
  group('normalizeLabel', () {
    test('normalizes basic labels', () {
      expect(normalizeLabel('PERSON'), equals(PERSON));
      expect(normalizeLabel('email'), equals(EMAIL));
      expect(normalizeLabel('PHONE_NUMBER'), equals(PHONE));
    });

    test('normalizes snake_case labels', () {
      expect(normalizeLabel('first_name'), equals(FIRST_NAME));
      expect(normalizeLabel('date_of_birth'), equals(DATE_OF_BIRTH));
    });

    test('normalizes UPPERCASE no-separator labels', () {
      expect(normalizeLabel('FIRSTNAME'), equals(FIRST_NAME));
      expect(normalizeLabel('DATEOFBIRTH'), equals(DATE_OF_BIRTH));
    });

    test('normalizes BIOES-tagged labels', () {
      expect(normalizeLabel('B-PERSON'), equals(PERSON));
      expect(normalizeLabel('I-EMAIL'), equals(EMAIL));
      expect(normalizeLabel('E-ADDRESS'), equals(STREET_ADDRESS));
      expect(normalizeLabel('S-PHONE'), equals(PHONE));
    });

    test('normalizes mixed case with separators', () {
      expect(normalizeLabel('First-Name'), equals(FIRST_NAME));
      expect(normalizeLabel('First Name'), equals(FIRST_NAME));
      expect(normalizeLabel('  Phone Number  '), equals(PHONE));
    });

    test('normalizes medical specific labels', () {
      expect(normalizeLabel('patient_id'), equals(PATIENT_ID));
      expect(normalizeLabel('DRUGNAME'), equals(DRUG_NAME));
      expect(normalizeLabel('diag_code'), equals(DIAGNOSIS_CODE));
    });

    test('returns OTHER for unknown labels', () {
      expect(normalizeLabel('UNKNOWN_ENTITY_TYPE'), equals(OTHER));
      expect(normalizeLabel(''), equals(OTHER));
    });

    test('handles canonical labels directly', () {
      expect(normalizeLabel('CREDIT_CARD'), equals(CREDIT_CARD));
      expect(normalizeLabel('MEDICAL_RECORD_NUMBER'), equals(MEDICAL_RECORD_NUMBER));
    });
  });

  group('PII_ENTITY_META', () {
    test('contains expected metadata for PERSON', () {
      final meta = PII_ENTITY_META[PERSON];
      expect(meta, isNotNull);
      expect(meta!['category'], equals('PII'));
      expect(meta['color'], equals('blue'));
    });

    test('contains expected metadata for MEDICAL_RECORD_NUMBER', () {
      final meta = PII_ENTITY_META[MEDICAL_RECORD_NUMBER];
      expect(meta, isNotNull);
      expect(meta!['category'], equals('PHI'));
      expect(meta['color'], equals('purple'));
    });

    test('contains expected metadata for DRUG_NAME', () {
      final meta = PII_ENTITY_META[DRUG_NAME];
      expect(meta, isNotNull);
      expect(meta!['category'], equals('MEDICAL'));
      expect(meta['color'], equals('purple'));
    });
  });
}
