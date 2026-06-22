import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/sync/infrastructure/services/rda_parser.dart';

void main() {
  group('RdaParser', () {
    test('parse returns null for non-Bundle/Composition', () {
      final result = RdaParser.parse({'resourceType': 'Patient'});
      expect(result, isNull);
    });

    test('parse handles single Composition', () {
      final composition = {
        'resourceType': 'Composition',
        'id': 'comp1',
        'title': 'Summary',
        'status': 'final',
        'date': '2024-01-01',
        'subject': {'display': 'John Doe'},
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
              'name': [{'given': ['John'], 'family': 'Doe'}]
            }
          },
          {
            'resource': {
              'resourceType': 'MedicationStatement',
              'medicationCodeableConcept': {'text': 'Aspirin'}
            }
          }
        ]
      };
      final result = RdaParser.parse(bundle);
      expect(result!['title'], 'Synthetic Summary');
      expect(result['patient'], 'John Doe');
      expect(result['sections'].length, 1);
      expect(result['sections'][0]['title'], 'Medications');
    });

    test('parse returns null for empty Bundle', () {
      final result = RdaParser.parse({'resourceType': 'Bundle', 'entry': []});
      expect(result, isNull);
    });

    test('_extractDisplay handles missing display', () {
      final composition = {
        'resourceType': 'Composition',
        'id': 'comp1',
        'subject': {'reference': 'Patient/p1'}
      };
      final result = RdaParser.parse(composition);
      expect(result!['patient'], 'Patient/p1');
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
          }
        ]
      };
      final result = RdaParser.parse(bundle);
      final entries = result!['sections'][0]['entries'];
      expect(entries[0]['id'], 'o1');
      expect(entries[1]['id'], 'o2');
      expect(entries[2]['id'], 'o3');
    });

    test('_resolveReference handles contained resources', () {
      final composition = {
        'resourceType': 'Composition',
        'contained': [
          {'resourceType': 'Practitioner', 'id': 'p1', 'name': [{'text': 'Dr. Smith'}]}
        ],
        'section': [
          {
            'entry': [{'reference': '#p1'}]
          }
        ]
      };
      final result = RdaParser.parse(composition);
      expect(result!['sections'][0]['entries'][0]['name'][0]['text'], 'Dr. Smith');
    });
  });
}
