import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:just_audio/just_audio.dart';
import 'package:orionhealth_health/core/services/tts/sherpa_onnx_adapter.dart';
import 'package:orionhealth_health/core/services/tts/tts_types.dart';
import 'package:orionhealth_health/core/services/tts/tts_adapter.dart';

class MockAudioPlayer extends Mock implements AudioPlayer {}

void main() {
  group('SherpaOnnxTTSAdapter', () {
    late SherpaOnnxTTSAdapter adapter;
    late MockAudioPlayer mockPlayer;
    String? lastError;

    setUp(() {
      mockPlayer = MockAudioPlayer();
      adapter = SherpaOnnxTTSAdapter(
        player: mockPlayer,
        callbacks: TTSCallbacks(
          onError: (m) => lastError = m,
        ),
      );

      when(() => mockPlayer.playerStateStream).thenAnswer((_) => const Stream.empty());
      when(() => mockPlayer.stop()).thenAnswer((_) async {});
      when(() => mockPlayer.playing).thenReturn(false);
    });

    test('initialize failing due to missing assets/manifest', () async {
      // Mock path_provider channel to avoid MissingPluginException
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'),
        (MethodCall methodCall) async {
          return '.';
        },
      );

      await adapter.initialize();
      expect(adapter.state, TTSState.initialized);
    });

    test('speak fails when model not found', () async {
      await adapter.speak('Hello');
      expect(lastError, contains('not found in catalog'));
    });
  });
}
