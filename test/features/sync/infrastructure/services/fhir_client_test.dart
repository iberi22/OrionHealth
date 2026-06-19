import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/sync/infrastructure/services/fhir_client.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  late FhirClient fhirClient;
  late MockHttpClient mockHttpClient;
  const baseUrl = 'https://test.fhir.org';
  const token = 'test-token';

  setUpAll(() {
    registerFallbackValue(Uri());
  });

  setUp(() {
    mockHttpClient = MockHttpClient();
    fhirClient = FhirClient(baseUrl: baseUrl, client: mockHttpClient);
  });

  group('FhirClient', () {
    test('getPatient returns data on 200', () async {
      final mockData = {'resourceType': 'Patient', 'id': '123'};
      when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(jsonEncode(mockData), 200));

      final result = await fhirClient.getPatient('123', token);

      expect(result['id'], '123');
      verify(() => mockHttpClient.get(
            Uri.parse('$baseUrl/Patient/123'),
            headers: any(named: 'headers'),
          )).called(1);
    });

    test('getPatient throws FhirException on error status', () async {
      when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response('Error', 400));

      expect(
        () => fhirClient.getPatient('123', token),
        throwsA(isA<FhirException>()),
      );
    });

    test('getPatient throws FhirException on network error', () async {
      when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
          .thenThrow(Exception('No connection'));

      expect(
        () => fhirClient.getPatient('123', token),
        throwsA(isA<FhirException>()),
      );
    });

    test('getRDA returns data on 200', () async {
      final mockData = {'resourceType': 'Bundle', 'total': 1};
      when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(jsonEncode(mockData), 200));

      final result = await fhirClient.getRDA('p123', token);

      expect(result['total'], 1);
      final capturedUri = verify(() => mockHttpClient.get(
            captureAny(),
            headers: any(named: 'headers'),
          )).captured.single as Uri;

      expect(capturedUri.path, '/Composition');
      expect(capturedUri.queryParameters['patient'], 'p123');
    });

    test('searchPatient throws ArgumentError if no params', () async {
      expect(
        () => fhirClient.searchPatient(accessToken: token),
        throwsArgumentError,
      );
    });

    test('searchPatient returns data on 200', () async {
      final mockData = {'resourceType': 'Bundle', 'total': 1};
      when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(jsonEncode(mockData), 200));

      final result = await fhirClient.searchPatient(
        identifier: 'doc123',
        name: 'John',
        birthDate: '1990-01-01',
        accessToken: token,
      );

      expect(result['total'], 1);
      final capturedUri = verify(() => mockHttpClient.get(
            captureAny(),
            headers: any(named: 'headers'),
          )).captured.single as Uri;

      expect(capturedUri.queryParameters['identifier'], 'doc123');
      expect(capturedUri.queryParameters['name'], 'John');
      expect(capturedUri.queryParameters['birthdate'], '1990-01-01');
    });

    test('fetchResource returns data on 200', () async {
      final mockData = {'id': 'o1'};
      when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(jsonEncode(mockData), 200));

      final result = await fhirClient.fetchResource('Observation', 'o1', token);

      expect(result!['id'], 'o1');
    });

    test('fetchResource returns null on 404', () async {
      when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response('Not Found', 404));

      final result = await fhirClient.fetchResource('Observation', 'o1', token);

      expect(result, isNull);
    });

    test('dispose closes client', () {
      fhirClient.dispose();
      verify(() => mockHttpClient.close()).called(1);
    });
  });
}
