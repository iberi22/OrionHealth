import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/medical_research/infrastructure/bot_bypass_handler.dart';

void main() {
  late BotBypassHandler handler;

  setUp(() {
    handler = BotBypassHandler();
  });

  group('BotBypassHandler', () {
    test('getRandomUserAgent returns a valid user agent string', () {
      final ua = handler.getRandomUserAgent();

      expect(ua, isNotEmpty);
      expect(ua, startsWith('Mozilla/5.0'));
      // Must contain at least one of expected browser engine identifiers
      final hasEngine = ua.contains('AppleWebKit') ||
          ua.contains('Gecko') ||
          ua.contains('Safari');
      expect(hasEngine, isTrue);
    });

    test('getRandomUserAgent returns a different user agent on repeated calls', () {
      final agents = <String>{};
      for (int i = 0; i < 20; i++) {
        agents.add(handler.getRandomUserAgent());
      }

      // With 5 options and random selection, 20 calls should hit at least 2 different agents
      expect(agents.length, greaterThan(1));
    });

    test('getHeaders returns map with expected keys', () {
      final headers = handler.getHeaders();

      expect(headers, containsPair('Accept', contains('text/html')));
      expect(headers, containsPair('Accept-Language', 'en-US,en;q=0.9'));
      expect(headers, containsPair('Cache-Control', 'max-age=0'));
      expect(headers, containsPair('Upgrade-Insecure-Requests', '1'));
      expect(headers.containsKey('User-Agent'), isTrue);
      expect(headers['User-Agent'], startsWith('Mozilla/5.0'));
    });

    test('getHeaders includes a valid User-Agent', () {
      final headers = handler.getHeaders();
      final ua = headers['User-Agent'];

      expect(ua, isNotEmpty);
      expect(ua, startsWith('Mozilla/5.0'));
    });

    test('waitHumanTime delays between 1 and 3 seconds', () async {
      final stopwatch = Stopwatch()..start();
      await handler.waitHumanTime();
      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(1000));
      expect(stopwatch.elapsedMilliseconds, lessThanOrEqualTo(3500));
    });

    test('waitHumanTime can be called multiple times with varying delays', () async {
      final delays = <int>[];
      for (int i = 0; i < 5; i++) {
        final stopwatch = Stopwatch()..start();
        await handler.waitHumanTime();
        stopwatch.stop();
        delays.add(stopwatch.elapsedMilliseconds);
      }

      // Verify all delays are within 1-3.5s range
      for (final d in delays) {
        expect(d, greaterThanOrEqualTo(1000));
        expect(d, lessThanOrEqualTo(3500));
      }

      // With random variation, at least some should differ
      final uniqueDelays = delays.toSet();
      expect(uniqueDelays.length, greaterThan(1));
    });
  });
}
