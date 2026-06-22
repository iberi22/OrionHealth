import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/core/services/app_logger.dart';

void main() {
  group('AppLogger', () {
    test('d logs message', () {
      final logs = <String>[];
      runZoned(
        () => AppLogger.d('TAG', 'debug message'),
        zoneValues: {},
        zoneSpecification: ZoneSpecification(
          print: (self, parent, zone, message) {
            logs.add(message);
          },
        ),
      );
      expect(logs, contains('[TAG] DEBUG: debug message'));
    });

    test('i logs message', () {
      final logs = <String>[];
      runZoned(
        () => AppLogger.i('TAG', 'info message'),
        zoneValues: {},
        zoneSpecification: ZoneSpecification(
          print: (self, parent, zone, message) {
            logs.add(message);
          },
        ),
      );
      expect(logs, contains('[TAG] INFO: info message'));
    });

    test('w logs message', () {
      final logs = <String>[];
      runZoned(
        () => AppLogger.w('TAG', 'warning message'),
        zoneValues: {},
        zoneSpecification: ZoneSpecification(
          print: (self, parent, zone, message) {
            logs.add(message);
          },
        ),
      );
      expect(logs, contains('[TAG] WARN: warning message'));
    });

    test('e logs message with error and stacktrace', () {
      final logs = <String>[];
      final error = Exception('test error');
      final stackTrace = StackTrace.current;

      runZoned(
        () => AppLogger.e('TAG', 'error message', error: error, stackTrace: stackTrace),
        zoneValues: {},
        zoneSpecification: ZoneSpecification(
          print: (self, parent, zone, message) {
            logs.add(message);
          },
        ),
      );

      expect(logs, contains('[TAG] ERROR: error message | Exception: test error'));
      expect(logs, contains(stackTrace.toString()));
    });
  });
}
