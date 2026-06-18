import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/local_agent/domain/entities/medical_code.dart';

void main() {
  group('MedicalCode', () {
    const testCode = MedicalCode(
      code: 'E11',
      displayName: 'Type 2 Diabetes Mellitus',
      category: 'Endocrine',
      standard: 'ICD-10',
      searchTerms: ['diabetes', 'type 2', 'mellitus'],
      definition: 'A chronic metabolic disorder',
      mentalHealthImpact: 'May cause depression',
      physicalHealthImpact: 'Affects multiple organ systems',
      referenceValues: {'fastingGlucose': '>126 mg/dL'},
      parentCode: 'E00-E89',
      childCodes: ['E11.0', 'E11.1'],
      firstLineTreatment: 'Metformin',
      alternatives: 'Sulfonylureas, SGLT2 inhibitors',
      redFlags: 'Diabetic ketoacidosis',
      followUp: 'HbA1c every 3 months',
    );

    test('constructor assigns all fields correctly', () {
      expect(testCode.code, 'E11');
      expect(testCode.displayName, 'Type 2 Diabetes Mellitus');
      expect(testCode.category, 'Endocrine');
      expect(testCode.standard, 'ICD-10');
      expect(testCode.searchTerms, ['diabetes', 'type 2', 'mellitus']);
      expect(testCode.definition, 'A chronic metabolic disorder');
      expect(testCode.mentalHealthImpact, 'May cause depression');
      expect(testCode.physicalHealthImpact, 'Affects multiple organ systems');
      expect(testCode.referenceValues, {'fastingGlucose': '>126 mg/dL'});
      expect(testCode.parentCode, 'E00-E89');
      expect(testCode.childCodes, ['E11.0', 'E11.1']);
      expect(testCode.firstLineTreatment, 'Metformin');
      expect(testCode.alternatives, 'Sulfonylureas, SGLT2 inhibitors');
      expect(testCode.redFlags, 'Diabetic ketoacidosis');
      expect(testCode.followUp, 'HbA1c every 3 months');
    });

    test('constructor uses defaults for optional fields', () {
      const minimal = MedicalCode(
        code: 'A00',
        displayName: 'Cholera',
        category: 'Infectious',
        standard: 'ICD-10',
      );

      expect(minimal.searchTerms, []);
      expect(minimal.definition, isNull);
      expect(minimal.mentalHealthImpact, isNull);
      expect(minimal.physicalHealthImpact, isNull);
      expect(minimal.referenceValues, isNull);
      expect(minimal.parentCode, isNull);
      expect(minimal.childCodes, []);
      expect(minimal.firstLineTreatment, isNull);
      expect(minimal.alternatives, isNull);
      expect(minimal.redFlags, isNull);
      expect(minimal.followUp, isNull);
    });

    group('fromJson', () {
      test('parses full JSON correctly', () {
        final json = {
          'code': 'J45',
          'displayName': 'Asthma',
          'category': 'Respiratory',
          'searchTerms': ['asthma', 'bronchial'],
          'definition': 'Chronic airway inflammation',
          'mentalHealthImpact': 'Anxiety from breathlessness',
          'physicalHealthImpact': 'Reduced exercise capacity',
          'referenceValues': {'peakFlow': '>80% predicted'},
          'parentCode': 'J00-J99',
          'childCodes': ['J45.0', 'J45.1'],
          'firstLineTreatment': 'Inhaled corticosteroids',
          'alternatives': 'Leukotriene modifiers',
          'redFlags': 'Silent chest',
          'followUp': 'Spirometry annually',
        };

        final code = MedicalCode.fromJson(json, 'ICD-10');

        expect(code.code, 'J45');
        expect(code.displayName, 'Asthma');
        expect(code.standard, 'ICD-10');
        expect(code.searchTerms, ['asthma', 'bronchial']);
        expect(code.definition, 'Chronic airway inflammation');
        expect(code.firstLineTreatment, 'Inhaled corticosteroids');
        expect(code.redFlags, 'Silent chest');
      });

      test('handles missing optional fields', () {
        final json = {
          'code': 'I10',
          'displayName': 'Essential Hypertension',
          'category': 'Cardiovascular',
        };

        final code = MedicalCode.fromJson(json, 'ICD-10');

        expect(code.code, 'I10');
        expect(code.searchTerms, []);
        expect(code.definition, isNull);
        expect(code.childCodes, []);
        expect(code.firstLineTreatment, isNull);
      });

      test('handles empty searchTerms', () {
        final json = {
          'code': 'K21',
          'displayName': 'GERD',
          'category': 'Digestive',
          'searchTerms': [],
        };

        final code = MedicalCode.fromJson(json, 'ICD-10');

        expect(code.searchTerms, []);
      });
    });

    group('Equatable', () {
      test('identical codes are equal', () {
        const code1 = MedicalCode(
          code: 'E11',
          displayName: 'T2DM',
          category: 'Endo',
          standard: 'ICD-10',
        );
        const code2 = MedicalCode(
          code: 'E11',
          displayName: 'T2DM',
          category: 'Endo',
          standard: 'ICD-10',
        );

        expect(code1, equals(code2));
      });

      test('different codes are not equal', () {
        const code1 = MedicalCode(
          code: 'E11',
          displayName: 'T2DM',
          category: 'Endo',
          standard: 'ICD-10',
        );
        const code2 = MedicalCode(
          code: 'E10',
          displayName: 'T1DM',
          category: 'Endo',
          standard: 'ICD-10',
        );

        expect(code1, isNot(equals(code2)));
      });
    });

    group('allSearchableTerms', () {
      test(
        'includes displayName, searchTerms, and non-null clinical fields',
        () {
          final terms = testCode.allSearchableTerms;

          expect(terms, contains('Type 2 Diabetes Mellitus'));
          expect(terms, contains('diabetes'));
          expect(terms, contains('A chronic metabolic disorder'));
          expect(terms, contains('Metformin'));
          expect(terms, contains('Sulfonylureas, SGLT2 inhibitors'));
          expect(terms, contains('Diabetic ketoacidosis'));
          expect(terms, contains('HbA1c every 3 months'));
        },
      );

      test('excludes null fields', () {
        const minimal = MedicalCode(
          code: 'A00',
          displayName: 'Cholera',
          category: 'Infectious',
          standard: 'ICD-10',
        );

        final terms = minimal.allSearchableTerms;

        expect(terms, ['Cholera']);
      });
    });

    group('embeddingText', () {
      test('builds complete embedding text from all non-null fields', () {
        final text = testCode.embeddingText;

        expect(text, contains(testCode.displayName));
        expect(text, contains('diabetes, type 2, mellitus'));
        expect(text, contains('A chronic metabolic disorder'));
        expect(text, contains('May cause depression'));
        expect(text, contains('Affects multiple organ systems'));
        expect(text, contains('Metformin'));
        expect(text, contains('Sulfonylureas, SGLT2 inhibitors'));
        expect(text, contains('Diabetic ketoacidosis'));
        expect(text, contains('HbA1c every 3 months'));
      });

      test('includes only available fields when many are null', () {
        const minimal = MedicalCode(
          code: 'A00',
          displayName: 'Cholera',
          category: 'Infectious',
          standard: 'ICD-10',
          searchTerms: ['c\u00f3lera', 'vibrio'],
        );

        final text = minimal.embeddingText;

        expect(text, contains('Cholera'));
        expect(text, contains('c\u00f3lera, vibrio'));
        expect(text, isNot(contains('Definition:')));
        expect(text, isNot(contains('Mental Health:')));
        expect(text, isNot(contains('First-line Treatment:')));
      });
    });
  });
}
