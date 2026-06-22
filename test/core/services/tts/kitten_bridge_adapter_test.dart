import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:orionhealth_health/core/services/tts/kitten_bridge_adapter.dart';
import 'package:orionhealth_health/core/services/tts/tts_types.dart';
import 'package:orionhealth_health/core/services/tts/tts_adapter.dart';

class MockHttpClient extends Mock implements http.Client {}
class MockAudioPlayer extends Mock implements AudioPlayer {}

void main() {
  setUpAll(() {
    registerFallbackValue(Uri.parse('http://localhost'));
  });

  group('KittenBridgeAdapter', () {
    late KittenBridgeAdapter adapter;
    late MockHttpClient mockClient;
    late MockAudioPlayer mockPlayer;
    late List<String> errors;

    setUp(() {
      mockClient = MockHttpClient();
      mockPlayer = MockAudioPlayer();
      errors = [];
      adapter = KittenBridgeAdapter(
        httpClient: mockClient,
        player: mockPlayer,
        callbacks: TTSCallbacks(
          onError: (m) => errors.add(m),
        ),
      );

      when(() => mockPlayer.playerStateStream).thenAnswer((_) => Stream.empty());
      when(() => mockPlayer.setFilePath(any())).thenAnswer((_) async => null);
      when(() => mockPlayer.play()).thenAnswer((_) async => null);
      when(() => mockPlayer.stop()).thenAnswer((_) async => null);
      when(() => mockPlayer.playing).thenReturn(false);
    });

    test('initialize sets state', () async {
      when(() => mockPlayer.playerStateStream).thenAnswer((_) => const Stream.empty());
      await adapter.initialize();
      expect(adapter.state, TTSState.initialized);
    });

    test('speak calls bridge and plays audio', () async {
      final controller = StreamController<PlayerState>.broadcast();
      when(() => mockPlayer.playerStateStream).thenAnswer((_) => controller.stream);
      when(() => mockClient.post(any(), headers: any(named: 'headers'), body: any(named: 'body')))
          .thenAnswer((_) async => http.Response.bytes(Uint8List(100), 200));

      final future = adapter.speak('Hello world');

      // wait for bridge call and file write
      await Future.delayed(const Duration(milliseconds: 100));

      verify(() => mockClient.post(
        any(),
        headers: any(named: 'headers'),
        body: any(named: 'body'),
      )).called(1);
      verify(() => mockPlayer.setFilePath(any())).called(1);
      verify(() => mockPlayer.play()).called(1);

      controller.add(PlayerState(false, ProcessingState.completed));
      await future;
      controller.close();
    });

    test('speak handles bridge error', () async {
      when(() => mockClient.post(any(), headers: any(named: 'headers'), body: any(named: 'body')))
          .thenAnswer((_) async => http.Response('Error', 500));

      await adapter.speak('Hello');

      expect(adapter.state, TTSState.error);
      expect(errors.any((e) => e.contains('500')), isTrue);
    });

    test('stop stops player', () async {
      when(() => mockPlayer.playing).thenReturn(true);
      await adapter.stop();
      verify(() => mockPlayer.stop()).called(1);
      expect(adapter.state, TTSState.stopped);
    });
  });
}
