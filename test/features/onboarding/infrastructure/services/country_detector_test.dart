import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/onboarding/infrastructure/services/country_detector.dart';
import 'package:orionhealth_health/features/onboarding/presentation/pages/onboarding_welcome_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockClient extends Mock implements http.Client {}

class MockCountryDetector extends Mock implements CountryDetector {}

void main() {
  late MockClient mockClient;
  late CountryDetector detector;

  setUpAll(() {
    registerFallbackValue(Uri());
  });

  setUp(() {
    mockClient = MockClient();
    detector = CountryDetector(client: mockClient);
    SharedPreferences.setMockInitialValues({});
  });

  group('CountryDetector Providers', () {
    test('ipapi.co returns country code', () async {
      when(() => mockClient.get(Uri.parse('https://ipapi.co/json/')))
          .thenAnswer((_) async => http.Response(
                json.encode({'country_code': 'CO'}),
                200,
              ));

      final result = await detector.detectCountry();
      expect(result, 'CO');
      verify(() => mockClient.get(Uri.parse('https://ipapi.co/json/'))).called(1);
    });

    test('falls back to ip-api.com if ipapi.co fails', () async {
      when(() => mockClient.get(Uri.parse('https://ipapi.co/json/')))
          .thenThrow(Exception('Network error'));
      when(() => mockClient.get(Uri.parse('http://ip-api.com/json/?fields=countryCode')))
          .thenAnswer((_) async => http.Response(
                json.encode({'countryCode': 'US'}),
                200,
              ));

      final result = await detector.detectCountry();
      expect(result, 'US');
      verify(() => mockClient.get(Uri.parse('https://ipapi.co/json/'))).called(1);
      verify(() => mockClient.get(Uri.parse('http://ip-api.com/json/?fields=countryCode'))).called(1);
    });

    test('falls back to ipinfo.io if first two fail', () async {
      when(() => mockClient.get(Uri.parse('https://ipapi.co/json/')))
          .thenAnswer((_) async => http.Response('Error', 500));
      when(() => mockClient.get(Uri.parse('http://ip-api.com/json/?fields=countryCode')))
          .thenAnswer((_) async => http.Response('Error', 500));
      when(() => mockClient.get(Uri.parse('https://ipinfo.io/json')))
          .thenAnswer((_) async => http.Response(
                json.encode({'country': 'AR'}),
                200,
              ));

      final result = await detector.detectCountry();
      expect(result, 'AR');
      verify(() => mockClient.get(Uri.parse('https://ipapi.co/json/'))).called(1);
      verify(() => mockClient.get(Uri.parse('http://ip-api.com/json/?fields=countryCode'))).called(1);
      verify(() => mockClient.get(Uri.parse('https://ipinfo.io/json'))).called(1);
    });

    test('returns null if all providers fail', () async {
      when(() => mockClient.get(any()))
          .thenAnswer((_) async => http.Response('Error', 500));

      final result = await detector.detectCountry();
      expect(result, isNull);
    });
  });

  group('CountryDetector Logic & Cache', () {
    test('isColombia returns true for CO', () async {
      when(() => mockClient.get(any()))
          .thenAnswer((_) async => http.Response(json.encode({'country_code': 'CO'}), 200));

      final result = await detector.isColombia();
      expect(result, isTrue);
    });

    test('isColombia returns false for others', () async {
      when(() => mockClient.get(any()))
          .thenAnswer((_) async => http.Response(json.encode({'country_code': 'US'}), 200));

      final result = await detector.isColombia();
      expect(result, isFalse);
    });

    test('normalization trims and uppercases country code', () async {
      when(() => mockClient.get(any()))
          .thenAnswer((_) async => http.Response(json.encode({'country_code': '  co  '}), 200));

      final result = await detector.detectCountry();
      expect(result, 'CO');
    });

    test('cache is used if within 24h', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      SharedPreferences.setMockInitialValues({
        'detected_country_code': 'CO',
        'detected_country_time': now - Duration(hours: 23).inMilliseconds,
      });

      final result = await detector.detectCountry();
      expect(result, 'CO');
      verifyNever(() => mockClient.get(any()));
    });

    test('cache is ignored if older than 24h', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      SharedPreferences.setMockInitialValues({
        'detected_country_code': 'CO',
        'detected_country_time': now - Duration(hours: 25).inMilliseconds,
      });

      when(() => mockClient.get(any()))
          .thenAnswer((_) async => http.Response(json.encode({'country_code': 'US'}), 200));

      final result = await detector.detectCountry();
      expect(result, 'US');
      verify(() => mockClient.get(any())).called(1);
    });
  });

  group('OnboardingWelcomePage Widget Test', () {
    late MockCountryDetector mockDetector;

    setUp(() {
      mockDetector = MockCountryDetector();
    });

    testWidgets('shows EPS section when in Colombia', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      when(() => mockDetector.isColombia()).thenAnswer((_) async => true);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: OnboardingWelcomePage(
            onNext: () {},
            onEpsDataReceived: (_) {},
            countryDetector: mockDetector,
          ),
        ),
      ));

      // Wait for country detection
      await tester.pumpAndSettle();

      // Navigate to the last slide
      await tester.tap(find.text('Siguiente'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Siguiente'));
      await tester.pumpAndSettle();

      expect(find.text('Conectá tu EPS para importar tus datos'), findsOneWidget);
    });

    testWidgets('hides EPS section when NOT in Colombia', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      when(() => mockDetector.isColombia()).thenAnswer((_) async => false);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: OnboardingWelcomePage(
            onNext: () {},
            onEpsDataReceived: (_) {},
            countryDetector: mockDetector,
          ),
        ),
      ));

      // Wait for country detection
      await tester.pumpAndSettle();

      // Navigate to the last slide
      await tester.tap(find.text('Siguiente'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Siguiente'));
      await tester.pumpAndSettle();

      expect(find.text('Conectá tu EPS para importar tus datos'), findsNothing);
    });
  });
}
