import 'dart:collection';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/email-citas/infrastructure/repositories/email_repository_impl.dart';
import 'package:orionhealth_health/features/appointments/domain/entities/appointment.dart';
import 'package:flutter/services.dart';
import 'package:device_calendar/device_calendar.dart';
import 'package:timezone/data/latest.dart' as tz;

class MockHttpClient extends Mock implements http.Client {}

class MockDeviceCalendarPlugin extends Mock implements DeviceCalendarPlugin {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late EmailRepositoryImpl repository;
  late MockHttpClient mockHttpClient;
  late MockDeviceCalendarPlugin mockDeviceCalendarPlugin;

  setUpAll(() {
    tz.initializeTimeZones();
    registerFallbackValue(Uri.parse('http://localhost'));
    registerFallbackValue(Event('calendarId'));
  });

  setUp(() {
    mockHttpClient = MockHttpClient();
    mockDeviceCalendarPlugin = MockDeviceCalendarPlugin();
    repository = EmailRepositoryImpl(
      client: mockHttpClient,
      deviceCalendarPlugin: mockDeviceCalendarPlugin,
    );
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
      expect(result.first.source, 'Gmail');
    });

    test('returns list of appointments for Outlook', () async {
      final responseBody = jsonEncode([
        {
          'doctorName': 'Dr. Wilson',
          'specialty': 'Oncology',
          'dateStr': '2025-10-11T10:00:00Z',
          'location': 'Princeton Plainsboro',
          'insurer': 'Medical'
        }
      ]);

      when(() => mockHttpClient.post(any(), headers: any(named: 'headers'), body: any(named: 'body')))
          .thenAnswer((_) async => http.Response(responseBody, 200));

      final result = await repository.fetchParsedAppointments('Outlook', 'test_code');

      expect(result.length, 1);
      expect(result.first.doctorName, 'Dr. Wilson');
      expect(result.first.source, 'Outlook');
    });

    test('throws exception on non-200', () async {
      when(() => mockHttpClient.post(any(), headers: any(named: 'headers'), body: any(named: 'body')))
          .thenAnswer((_) async => http.Response('Error', 400));

      expect(() => repository.fetchParsedAppointments('Gmail', 'test_code'), throwsException);
    });

    test('throws exception on invalid JSON', () async {
      when(() => mockHttpClient.post(any(), headers: any(named: 'headers'), body: any(named: 'body')))
          .thenAnswer((_) async => http.Response('Invalid JSON', 200));

      expect(() => repository.fetchParsedAppointments('Gmail', 'test_code'), throwsA(isA<FormatException>()));
    });
  });

  group('Connection Methods', () {
    const MethodChannel channel = MethodChannel('plugins.flutter.io/url_launcher');
    final List<MethodCall> log = <MethodCall>[];

    setUp(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        log.add(methodCall);
        if (methodCall.method == 'canLaunch') {
          return true;
        }
        if (methodCall.method == 'launch') {
          return true;
        }
        return null;
      });
    });

    tearDown(() {
      log.clear();
    });

    test('connectGmail calls launchUrl with correct parameters', () async {
      final result = await repository.connectGmail();

      expect(result, true);
      expect(log.any((call) => call.method == 'launch' && call.arguments['url'].contains('accounts.google.com')), true);
    });

    test('connectOutlook calls launchUrl with correct parameters', () async {
      final result = await repository.connectOutlook();

      expect(result, true);
      expect(log.any((call) => call.method == 'launch' && call.arguments['url'].contains('login.microsoftonline.com')), true);
    });
  });

  group('syncToNativeCalendar', () {
    Result<T> _successResult<T>(T data) {
      final result = Result<T>();
      result.data = data;
      result.errors = [];
      return result;
    }

    test('successfully creates event in native calendar', () async {
      final calendar = Calendar();
      calendar.id = '1';
      calendar.name = 'Default';

      when(() => mockDeviceCalendarPlugin.hasPermissions()).thenAnswer((_) async => _successResult(true));
      when(() => mockDeviceCalendarPlugin.retrieveCalendars()).thenAnswer((_) async => _successResult(UnmodifiableListView([calendar])));
      when(() => mockDeviceCalendarPlugin.createOrUpdateEvent(any())).thenAnswer((_) async => _successResult('event_id'));

      final appointment = Appointment(
        doctorName: 'Dr. Smith',
        specialty: 'Cardiology',
        dateTime: DateTime.now().add(const Duration(days: 1)),
        status: AppointmentStatus.upcoming,
        notes: 'Test notes',
      );

      await repository.syncToNativeCalendar(appointment);

      verify(() => mockDeviceCalendarPlugin.hasPermissions()).called(1);
      verify(() => mockDeviceCalendarPlugin.retrieveCalendars()).called(1);
      verify(() => mockDeviceCalendarPlugin.createOrUpdateEvent(any())).called(1);
    });

    test('requests permissions if not granted', () async {
      final calendar = Calendar();
      calendar.id = '1';

      when(() => mockDeviceCalendarPlugin.hasPermissions()).thenAnswer((_) async => _successResult(false));
      when(() => mockDeviceCalendarPlugin.requestPermissions()).thenAnswer((_) async => _successResult(true));
      when(() => mockDeviceCalendarPlugin.retrieveCalendars()).thenAnswer((_) async => _successResult(UnmodifiableListView([calendar])));
      when(() => mockDeviceCalendarPlugin.createOrUpdateEvent(any())).thenAnswer((_) async => _successResult('event_id'));

      final appointment = Appointment(
        doctorName: 'Dr. Smith',
        specialty: 'Cardiology',
        dateTime: DateTime.now().add(const Duration(days: 1)),
        status: AppointmentStatus.upcoming,
      );

      await repository.syncToNativeCalendar(appointment);

      verify(() => mockDeviceCalendarPlugin.hasPermissions()).called(1);
      verify(() => mockDeviceCalendarPlugin.requestPermissions()).called(1);
      verify(() => mockDeviceCalendarPlugin.createOrUpdateEvent(any())).called(1);
    });

    test('returns early if permissions are denied after request', () async {
      when(() => mockDeviceCalendarPlugin.hasPermissions()).thenAnswer((_) async => _successResult(false));
      when(() => mockDeviceCalendarPlugin.requestPermissions()).thenAnswer((_) async => _successResult(false));

      final appointment = Appointment(
        doctorName: 'Dr. Smith',
        specialty: 'Cardiology',
        dateTime: DateTime.now().add(const Duration(days: 1)),
        status: AppointmentStatus.upcoming,
      );

      await repository.syncToNativeCalendar(appointment);

      verify(() => mockDeviceCalendarPlugin.hasPermissions()).called(1);
      verify(() => mockDeviceCalendarPlugin.requestPermissions()).called(1);
      verifyNever(() => mockDeviceCalendarPlugin.retrieveCalendars());
    });
  });
}
