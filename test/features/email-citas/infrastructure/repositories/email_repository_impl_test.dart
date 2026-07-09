import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/email-citas/infrastructure/repositories/email_repository_impl.dart';
import 'package:orionhealth_health/features/appointments/domain/entities/appointment.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'dart:collection';
import 'package:device_calendar/device_calendar.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class MockHttpClient extends Mock implements http.Client {}

class MockUrlLauncher extends Mock with MockPlatformInterfaceMixin implements UrlLauncherPlatform {}

class FakeLaunchOptions extends Fake implements LaunchOptions {}

class MockDeviceCalendarPlugin extends Mock implements DeviceCalendarPlugin {}

void main() {
  late EmailRepositoryImpl repository;
  late MockHttpClient mockHttpClient;
  late MockUrlLauncher mockUrlLauncher;
  late MockDeviceCalendarPlugin mockCalendar;

  setUpAll(() {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('UTC'));
    registerFallbackValue(Uri.parse('http://localhost'));
    registerFallbackValue(FakeLaunchOptions());
  });

  setUp(() {
    mockHttpClient = MockHttpClient();
    mockCalendar = MockDeviceCalendarPlugin();
    repository = EmailRepositoryImpl(mockHttpClient, mockCalendar);
    mockUrlLauncher = MockUrlLauncher();
    UrlLauncherPlatform.instance = mockUrlLauncher;
  });

  group('EmailRepositoryImpl', () {
    group('connect methods', () {
      test('connectGmail calls launchUrl', () async {
        when(() => mockUrlLauncher.launchUrl(any(), any())).thenAnswer((_) async => true);
        final result = await repository.connectGmail();
        expect(result, true);
        verify(() => mockUrlLauncher.launchUrl(any(that: contains('accounts.google.com')), any())).called(1);
      });

      test('connectGmail returns false if launchUrl fails', () async {
        when(() => mockUrlLauncher.launchUrl(any(), any())).thenAnswer((_) async => false);
        final result = await repository.connectGmail();
        expect(result, false);
      });

      test('connectOutlook calls launchUrl', () async {
        when(() => mockUrlLauncher.launchUrl(any(), any())).thenAnswer((_) async => true);
        final result = await repository.connectOutlook();
        expect(result, true);
        verify(() => mockUrlLauncher.launchUrl(any(that: contains('login.microsoftonline.com')), any())).called(1);
      });
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

        when(() => mockHttpClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenAnswer((_) async => http.Response(responseBody, 200));

        final result = await repository.fetchParsedAppointments('Gmail', 'test_code');

        expect(result.length, 1);
        expect(result.first.doctorName, 'Dr. House');
        expect(result.first.specialty, 'Diagnostics');
      });

      test('handles missing data with defaults', () async {
        final responseBody = jsonEncode([{}]);
        when(() => mockHttpClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenAnswer((_) async => http.Response(responseBody, 200));

        final result = await repository.fetchParsedAppointments('Outlook', 'test_code');
        expect(result.first.doctorName, 'Desconocido');
      });

      test('throws exception on non-200', () async {
        when(() => mockHttpClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenAnswer((_) async => http.Response('Error', 400));

        expect(() => repository.fetchParsedAppointments('Gmail', 'test_code'), throwsException);
      });

      test('throws exception on invalid JSON', () async {
        when(() => mockHttpClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenAnswer((_) async => http.Response('Invalid JSON', 200));

        expect(() => repository.fetchParsedAppointments('Gmail', 'test_code'), throwsException);
      });
    });

    group('syncToNativeCalendar', () {
      final appointment = Appointment(
        doctorName: 'Test',
        specialty: 'Test',
        dateTime: DateTime.now(),
        status: AppointmentStatus.upcoming,
      );

      test('returns early if permissions are denied', () async {
        when(() => mockCalendar.hasPermissions()).thenAnswer((_) async => Result<bool>()..data = false);
        when(() => mockCalendar.requestPermissions()).thenAnswer((_) async => Result<bool>()..data = false);

        await repository.syncToNativeCalendar(appointment);

        verifyNever(() => mockCalendar.retrieveCalendars());
      });

      test('requests permissions if not already granted', () async {
        when(() => mockCalendar.hasPermissions()).thenAnswer((_) async => Result<bool>()..data = false);
        when(() => mockCalendar.requestPermissions()).thenAnswer((_) async => Result<bool>()..data = true);
        when(() => mockCalendar.retrieveCalendars()).thenAnswer((_) async => Result<UnmodifiableListView<Calendar>>()..data = UnmodifiableListView([]));

        await repository.syncToNativeCalendar(appointment);

        verify(() => mockCalendar.requestPermissions()).called(1);
      });

      test('creates event if permissions granted and calendars available', () async {
        final calendar = Calendar(id: '1', name: 'Main');
        when(() => mockCalendar.hasPermissions()).thenAnswer((_) async => Result<bool>()..data = true);
        when(() => mockCalendar.retrieveCalendars()).thenAnswer((_) async => Result<UnmodifiableListView<Calendar>>()..data = UnmodifiableListView([calendar]));
        when(() => mockCalendar.createOrUpdateEvent(any())).thenAnswer((_) async => Result<String>()..data = 'event_id');

        registerFallbackValue(Event('1'));

        await repository.syncToNativeCalendar(appointment);

        verify(() => mockCalendar.createOrUpdateEvent(any())).called(1);
      });
    });
  });
}
