import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/email-citas/infrastructure/repositories/email_repository_impl.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  late EmailRepositoryImpl repository;
  late MockHttpClient mockHttpClient;

  setUp(() {
    mockHttpClient = MockHttpClient();
    repository = EmailRepositoryImpl(client: mockHttpClient);

    registerFallbackValue(Uri.parse('http://localhost'));
  });

  group('fetchParsedAppointments', () {
    test('returns list of appointments on 200', () async {
      final responseBody = jsonEncode([
        {
          'doctorName': 'Dr. House',
          'specialty': 'Diagnostics',
          'dateStr': '2025-10-10T10:00:00Z',
          'location': 'Princeton Plainsboro',
          'insurer': 'Medical'
        }
      ]);

      when(() => mockHttpClient.post(any(), headers: any(named: 'headers'), body: any(named: 'body')))
          .thenAnswer((_) async => http.Response(responseBody, 200));

      final result = await repository.fetchParsedAppointments('Gmail', 'test_code');

      expect(result.length, 1);
      expect(result.first.doctorName, 'Dr. House');
      expect(result.first.specialty, 'Diagnostics');
    });

    test('throws exception on non-200', () async {
      when(() => mockHttpClient.post(any(), headers: any(named: 'headers'), body: any(named: 'body')))
          .thenAnswer((_) async => http.Response('Error', 400));

      expect(() => repository.fetchParsedAppointments('Gmail', 'test_code'), throwsException);
    });
  });
}
