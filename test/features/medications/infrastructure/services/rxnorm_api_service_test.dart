import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/medications/infrastructure/services/rxnorm_api_service.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late RxNormApiService service;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    service = RxNormApiService(mockDio);
  });

  group('searchMedications', () {
    const query = 'aspirin';
    const url = 'https://rxnav.nlm.nih.gov/REST/drugs.json';

    test('should return a list of medications on success', () async {
      final mockResponse = {
        'drugGroup': {
          'conceptGroup': [
            {
              'conceptProperties': [
                {'name': 'Aspirin 81 MG Oral Tablet', 'rxcui': '243670', 'synonym': 'Aspirin Low Dose'},
              ]
            }
          ]
        }
      };

      when(() => mockDio.get(url, queryParameters: {'name': query}))
          .thenAnswer((_) async => Response(
                data: mockResponse,
                statusCode: 200,
                requestOptions: RequestOptions(path: url),
              ));

      final result = await service.searchMedications(query);

      expect(result, hasLength(1));
      expect(result.first.name, 'Aspirin 81 MG Oral Tablet');
      expect(result.first.rxNormCode, '243670');
    });

    test('should return an empty list when no drugs are found', () async {
      final mockResponse = {'drugGroup': {}};

      when(() => mockDio.get(url, queryParameters: {'name': query}))
          .thenAnswer((_) async => Response(
                data: mockResponse,
                statusCode: 200,
                requestOptions: RequestOptions(path: url),
              ));

      final result = await service.searchMedications(query);

      expect(result, isEmpty);
    });

    test('should return an empty list on DioException', () async {
      when(() => mockDio.get(url, queryParameters: {'name': query}))
          .thenThrow(DioException(requestOptions: RequestOptions(path: url)));

      final result = await service.searchMedications(query);

      expect(result, isEmpty);
    });
  });

  group('getMedicationDetails', () {
    const code = '243670';
    const url = 'https://rxnav.nlm.nih.gov/REST/rxcui/$code/allProperties.json';

    test('should return medication details on success', () async {
      final mockResponse = {
        'propConceptGroup': {
          'propConcept': [
            {'propName': 'RXNORM_NAME', 'propValue': 'Aspirin 81 MG Oral Tablet'},
            {'propName': 'DRUG_CLASS', 'propValue': 'Analgesic'},
          ]
        }
      };

      when(() => mockDio.get(url, queryParameters: {'propCategories': 'ATTRIBUTES'}))
          .thenAnswer((_) async => Response(
                data: mockResponse,
                statusCode: 200,
                requestOptions: RequestOptions(path: url),
              ));

      final result = await service.getMedicationDetails(code);

      expect(result, isNotNull);
      expect(result!.name, 'Aspirin 81 MG Oral Tablet');
      expect(result.drugClass, 'Analgesic');
    });

    test('should return null on DioException', () async {
      when(() => mockDio.get(url, queryParameters: {'propCategories': 'ATTRIBUTES'}))
          .thenThrow(DioException(requestOptions: RequestOptions(path: url)));

      final result = await service.getMedicationDetails(code);

      expect(result, isNull);
    });
  });
}
