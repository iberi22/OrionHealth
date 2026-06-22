import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/sync/infrastructure/services/rda_parser.dart';

void main() {
  group('RdaParser', () {
    test('parse returns synthetic summary for non-Bundle/Composition', () {
      final result = RdaParser.parse({
        'resourceType': 'Observation',
        'id': 'o1',
        'code': {
          'text': 'Heart rate'
        }
      });
      expect(result, isNotNull);
      expect(result!['title'], 'Synthetic Summary');
      expect(result['sections'].length, 1);
      expect(result['sections'][0]['title'], 'Observations');
      expect(result['sections'][0]['entries'][0]['id'], 'o1');
    });

    test('parse handles single Composition', () {
      final composition = {
        'resourceType': 'Composition',
        'id': 'comp1',
        'title': 'Summary',
        'status': 'final',
        'date': '2024-01-01',
        'subject': {'display': 'John Doe'},
        'author': [
          {'display': 'Dr. Smith'}
        ],
        'type': {
          'coding': [
            {'code': '11488-4'}
          ]
        },
        'section': [
          {
            'title': 'Allergies',
            'code': {
              'coding': [
                {'code': '48765-2'}
              ]
            },
            'text': {'div': 'None known'}
          }
        ]
      };
      final result = RdaParser.parse(composition);
      expect(result!['id'], 'comp1');
      expect(result['author'], 'Dr. Smith');
      expect(result['type'], '11488-4');
      expect(result['sections'].length, 1);
      expect(result['sections'][0]['title'], 'Allergies');
    });

    test('parse handles Bundle with Composition', () {
      final bundle = {
        'resourceType': 'Bundle',
        'entry': [
          {
            'resource': {
              'resourceType': 'Composition',
              'id': 'comp1',
              'title': 'Summary',
              'section': [
                {
                  'title': 'Vitals',
                  'entry': [
                    {'reference': 'Observation/o1'}
                  ]
                }
              ]
            }
          },
          {
            'fullUrl': 'Observation/o1',
            'resource': {
              'resourceType': 'Observation',
              'id': 'o1',
              'valueString': '98bpm'
            }
          }
        ]
      };
      final result = RdaParser.parse(bundle);
      expect(result!['id'], 'comp1');
      expect(result['sections'][0]['entries'].length, 1);
      expect(result['sections'][0]['entries'][0]['resourceType'], 'Observation');
    });

    test('parse returns synthetic summary for Bundle without Composition', () {
      final bundle = {
        'resourceType': 'Bundle',
        'entry': [
          {
            'resource': {
              'resourceType': 'Patient',
              'name': [
                {'given': ['John'], 'family': 'Doe'}
              ]
            }
          },
          {
            'resource': {
              'resourceType': 'MedicationStatement',
              'medicationCodeableConcept': {'text': 'Aspirin'}
            }
          },
          {
            'resource': {
              'resourceType': 'AllergyIntolerance',
              'code': {'text': 'Peanuts'}
            }
          },
          {
            'resource': {
              'resourceType': 'Condition',
              'code': {'text': 'Diabetes'}
            }
          }
        ]
      };
      final result = RdaParser.parse(bundle);
      expect(result!['title'], 'Synthetic Summary');
      expect(result['patient'], 'John Doe');
      expect(result['sections'].any((s) => s['title'] == 'Medications'), true);
      expect(result['sections'].any((s) => s['title'] == 'Allergies'), true);
      expect(result['sections'].any((s) => s['title'] == 'Conditions'), true);
    });

    test('parse returns empty synthetic summary for empty Bundle', () {
      final result = RdaParser.parse({'resourceType': 'Bundle', 'entry': []});
      expect(result, isNotNull);
      expect(result!['title'], 'Synthetic Summary');
      expect(result['sections'], isEmpty);
    });

    test('_extractDisplay handles various cases', () {
      // Test null
      expect(RdaParser.parse({
        'resourceType': 'Composition',
        'subject': null
      })!['patient'], 'Unknown');

      // Test display
      expect(RdaParser.parse({
        'resourceType': 'Composition',
        'subject': {'display': 'John'}
      })!['patient'], 'John');

      // Test text
      expect(RdaParser.parse({
        'resourceType': 'Composition',
        'subject': {'text': 'John Doe'}
      })!['patient'], 'John Doe');

      // Test reference
      expect(RdaParser.parse({
        'resourceType': 'Composition',
        'subject': {'reference': 'Patient/p1'}
      })!['patient'], 'Patient/p1');

      // Test identifier value
      expect(RdaParser.parse({
        'resourceType': 'Composition',
        'subject': {
          'identifier': {'value': 'ID123'}
        }
      })!['patient'], 'ID123');

      // Test identifier system
      expect(RdaParser.parse({
        'resourceType': 'Composition',
        'subject': {
          'identifier': {'system': 'SYS123'}
        }
      })!['patient'], 'SYS123');

      // Test unknown
      expect(RdaParser.parse({
        'resourceType': 'Composition',
        'subject': {}
      })!['patient'], 'Unknown');
    });

    test('_resolveReference handles various reference formats', () {
      final bundle = {
        'resourceType': 'Bundle',
        'entry': [
          {
            'resource': {
              'resourceType': 'Composition',
              'id': 'comp1',
              'section': [
                {
                  'title': 'S1',
                  'entry': [
                    {'reference': 'Ref1'},
                    {'reference': 'Observation/o2'},
                    {'reference': 'o3'},
                    {'reference': 'Observation/o4'},
                  ]
                }
              ]
            }
          },
          {
            'fullUrl': 'Ref1',
            'resource': {'resourceType': 'Observation', 'id': 'o1'}
          },
          {
            'resource': {'resourceType': 'Observation', 'id': 'o2'}
          },
          {
            'resource': {'resourceType': 'Observation', 'id': 'o3'}
          },
          {
            'resource': {'resourceType': 'Observation', 'id': 'o4'}
          }
        ]
      };
      final result = RdaParser.parse(bundle);
      final entries = result!['sections'][0]['entries'];
      expect(entries[0]['id'], 'o1');
      expect(entries[1]['id'], 'o2');
      expect(entries[2]['id'], 'o3');
      expect(entries[3]['id'], 'o4');
    });

    test('_resolveReference handles contained resources', () {
      final composition = {
        'resourceType': 'Composition',
        'contained': [
          {
            'resourceType': 'Practitioner',
            'id': 'p1',
            'name': [
              {'text': 'Dr. Smith'}
            ]
          }
        ],
        'section': [
          {
            'entry': [
              {'reference': '#p1'}
            ]
          }
        ]
      };
      final result = RdaParser.parse(composition);
      expect(result!['sections'][0]['entries'][0]['name'][0]['text'], 'Dr. Smith');
    });

    test('_createSyntheticComposition handles MedicationRequest', () {
      final bundle = {
        'resourceType': 'Bundle',
        'entry': [
          {
            'resource': {
              'resourceType': 'MedicationRequest',
              'medicationCodeableConcept': {'text': 'Tylenol'}
            }
          }
        ]
      };
      final result = RdaParser.parse(bundle);
      expect(result!['sections'][0]['title'], 'Medications');
    });

    test('_createSyntheticComposition handles Patient name edge cases', () {
      final bundle = {
        'resourceType': 'Bundle',
        'entry': [
          {
            'resource': {
              'resourceType': 'Patient',
              'name': [
                {'family': 'Doe'}
              ]
            }
          }
        ]
      };
      final result = RdaParser.parse(bundle);
      expect(result!['patient'], 'Doe');

      final bundle2 = {
        'resourceType': 'Bundle',
        'entry': [
          {
            'resource': {
              'resourceType': 'Patient',
              'name': [
                {'given': ['John']}
              ]
            }
          }
        ]
      };
      final result2 = RdaParser.parse(bundle2);
      expect(result2!['patient'], 'John');
    });

    test('_parseComposition handles empty type coding', () {
      final composition = {
        'resourceType': 'Composition',
        'id': 'comp1',
        'status': 'final',
        'type': {
          'coding': []
        }
      };
      final result = RdaParser.parse(composition);
      expect(result!['type'], isNull);
    });
  });
}
