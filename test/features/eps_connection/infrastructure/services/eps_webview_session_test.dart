import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:orionhealth_health/features/eps_connection/infrastructure/services/eps_webview_session.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}
class MockInAppWebViewController extends Mock implements InAppWebViewController {}

void main() {
  late EpsWebViewSession session;
  late MockFlutterSecureStorage mockStorage;
  late MockInAppWebViewController mockController;
  const epsId = 'test_eps';

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    mockController = MockInAppWebViewController();
    session = EpsWebViewSession(storage: mockStorage, epsId: epsId);

    // Default stubs for write/delete
    when(() => mockStorage.write(
      key: any(named: 'key'),
      value: any(named: 'value'),
      iOptions: any(named: 'iOptions'),
      aOptions: any(named: 'aOptions'),
    )).thenAnswer((_) async => {});

    when(() => mockStorage.delete(
      key: any(named: 'key'),
      iOptions: any(named: 'iOptions'),
      aOptions: any(named: 'aOptions'),
    )).thenAnswer((_) async => {});
  });

  group('EpsWebViewSession', () {
    test('hasActiveSession returns false when no cookies are stored', () async {
      when(() => mockStorage.read(key: any(named: 'key'))).thenAnswer((_) async => null);

      final result = await session.hasActiveSession();

      expect(result, isFalse);
    });

    test('hasActiveSession returns true when valid session exists', () async {
      final meta = jsonEncode({
        'capturedAt': DateTime.now().toIso8601String(),
        'epsId': epsId,
      });

      when(() => mockStorage.read(key: 'eps_session_${epsId}_cookies'))
          .thenAnswer((_) async => '[{"name": "test"}]');
      when(() => mockStorage.read(key: 'eps_session_${epsId}_meta'))
          .thenAnswer((_) async => meta);

      final result = await session.hasActiveSession();

      expect(result, isTrue);
    });

    test('hasActiveSession returns false and clears when session is expired (> 7 days)', () async {
      final oldDate = DateTime.now().subtract(const Duration(days: 8));
      final meta = jsonEncode({
        'capturedAt': oldDate.toIso8601String(),
        'epsId': epsId,
      });

      when(() => mockStorage.read(key: 'eps_session_${epsId}_cookies'))
          .thenAnswer((_) async => '[{"name": "test"}]');
      when(() => mockStorage.read(key: 'eps_session_${epsId}_meta'))
          .thenAnswer((_) async => meta);

      final result = await session.hasActiveSession();

      expect(result, isFalse);
      verify(() => mockStorage.delete(key: 'eps_session_${epsId}_cookies')).called(1);
    });

    test('trackNavigation appends to history and limits to 50 entries', () async {
      when(() => mockStorage.read(key: 'eps_session_${epsId}_nav_history'))
          .thenAnswer((_) async => null);

      await session.trackNavigation('https://test.com/1');

      verify(() => mockStorage.write(
            key: 'eps_session_${epsId}_nav_history',
            value: any(named: 'value', that: contains('https://test.com/1')),
            iOptions: any(named: 'iOptions'),
            aOptions: any(named: 'aOptions'),
          )).called(1);

      // Test limiting to 50
      final largeHistory = List.generate(50, (i) => {'url': 'url$i', 'timestamp': DateTime.now().toIso8601String()});
      when(() => mockStorage.read(key: 'eps_session_${epsId}_nav_history'))
          .thenAnswer((_) async => jsonEncode(largeHistory));

      await session.trackNavigation('https://test.com/new');

      final captured = verify(() => mockStorage.write(
            key: 'eps_session_${epsId}_nav_history',
            value: captureAny(named: 'value'),
            iOptions: any(named: 'iOptions'),
            aOptions: any(named: 'aOptions'),
          )).captured.last as String;

      final savedHistory = jsonDecode(captured) as List;
      expect(savedHistory.length, 50);
      expect(savedHistory.last['url'], 'https://test.com/new');
      expect(savedHistory.first['url'], 'url1');
    });

    test('saveLastUrl and getLastUrl interact correctly with storage', () async {
      when(() => mockStorage.read(key: 'eps_session_${epsId}_last_url'))
          .thenAnswer((_) async => 'https://last.com');

      await session.saveLastUrl('https://last.com');
      final lastUrl = await session.getLastUrl();

      expect(lastUrl, 'https://last.com');
      verify(() => mockStorage.write(
        key: 'eps_session_${epsId}_last_url',
        value: 'https://last.com',
        iOptions: any(named: 'iOptions'),
        aOptions: any(named: 'aOptions'),
      )).called(1);
    });

    test('clearSession deletes all session keys', () async {
      await session.clearSession();

      verify(() => mockStorage.delete(key: 'eps_session_${epsId}_cookies', iOptions: any(named: 'iOptions'), aOptions: any(named: 'aOptions'))).called(1);
      verify(() => mockStorage.delete(key: 'eps_session_${epsId}_nav_history', iOptions: any(named: 'iOptions'), aOptions: any(named: 'aOptions'))).called(1);
      verify(() => mockStorage.delete(key: 'eps_session_${epsId}_last_url', iOptions: any(named: 'iOptions'), aOptions: any(named: 'aOptions'))).called(1);
      verify(() => mockStorage.delete(key: 'eps_session_${epsId}_local_storage', iOptions: any(named: 'iOptions'), aOptions: any(named: 'aOptions'))).called(1);
      verify(() => mockStorage.delete(key: 'eps_session_${epsId}_meta', iOptions: any(named: 'iOptions'), aOptions: any(named: 'aOptions'))).called(1);
    });

    test('restoreLocalStorage evaluates javascript with escaped data', () async {
      const storedData = '{"key": "value\'s"}';
      when(() => mockStorage.read(key: 'eps_session_${epsId}_local_storage'))
          .thenAnswer((_) async => storedData);
      when(() => mockController.evaluateJavascript(source: any(named: 'source')))
          .thenAnswer((_) async => null);

      await session.restoreLocalStorage(mockController);

      final capturedSource = verify(() => mockController.evaluateJavascript(
            source: captureAny(named: 'source'),
          )).captured.first as String;

      expect(capturedSource, contains("value\\'s"));
    });
  });
}
