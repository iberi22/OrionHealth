import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/core/services/tts/system_tts_adapter.dart';
import 'package:orionhealth_health/core/services/tts/tts_types.dart';
import 'package:orionhealth_health/core/services/tts/tts_adapter.dart';

void main() {
  group('SystemTTSAdapter', () {
    late SystemTTSAdapter adapter;
    String? lastError;

    setUp(() {
      adapter = SystemTTSAdapter(
        callbacks: TTSCallbacks(
          onError: (msg) => lastError = msg,
        ),
      );
    });

    test('initialize reports error as it is a stub', () async {
      await adapter.initialize();
      expect(adapter.state, TTSState.error);
      expect(lastError, contains('not available'));
    });

    test('speak reports error', () async {
      await adapter.speak('Hello');
      expect(lastError, contains('not available'));
    });

    test('stop sets state to stopped', () async {
      await adapter.stop();
      expect(adapter.state, TTSState.stopped);
    });

    test('pause sets state to paused', () async {
      await adapter.pause();
      expect(adapter.state, TTSState.paused);
    });

    test('getLanguages returns defaults', () async {
      final langs = await adapter.getLanguages();
      expect(langs, contains('es-ES'));
    });
  });
}
