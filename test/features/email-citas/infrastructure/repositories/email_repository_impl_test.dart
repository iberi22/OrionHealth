import 'dart:convert';
import 'package:device_calendar/device_calendar.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/email-citas/infrastructure/repositories/email_repository_impl.dart';

class MockHttpClient extends Mock implements http.Client {}
class MockDeviceCalendarPlugin extends Mock implements DeviceCalendarPlugin {}

void main() {
  late EmailRepositoryImpl repository;
  late MockHttpClient mockClient;
  late MockDeviceCalendarPlugin mockCalendar;

  setUpAll(() {
    registerFallbackValue(Uri.parse('http://localhost'));
  });

  setUp(() {
    mockClient = MockHttpClient();
    mockCalendar = MockDeviceCalendarPlugin();
    repository = EmailRepositoryImpl(mockClient, mockCalendar);
  });

  group('EmailRepositoryImpl', () {
    test('fetchParsedAppointments returns appointments on 200', () async {
      final mockResponse = jsonEncode([
        {'doctorName': 'Dr. Gomez', 'specialty': 'General', 'dateStr': '2024-01-01T10:00:00Z'}
      ]);

      when(() => mockClient.post(any(), headers: any(named: 'headers'), body: any(named: 'body')))
          .thenAnswer((_) async => http.Response(mockResponse, 200));

      final result = await repository.fetchParsedAppointments('Gmail', 'code123');

      expect(result.length, 1);
      expect(result.first.doctorName, 'Dr. Gomez');
    });

    test('fetchParsedAppointments throws exception on error', () async {
      when(() => mockClient.post(any(), headers: any(named: 'headers'), body: any(named: 'body')))
          .thenAnswer((_) async => http.Response('Error', 400));

      expect(() => repository.fetchParsedAppointments('Gmail', 'code123'), throwsException);
    });
  });
}
