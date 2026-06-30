import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:orionhealth_health/core/services/asr/sherpa_onnx_asr_service.dart';
import 'package:orionhealth_health/core/services/asr/asr_types.dart';
import 'package:orionhealth_health/core/services/asr/asr_model_manager.dart';
import 'package:orionhealth_health/core/services/asr/asr_model_manifest.dart';

class MockOnDeviceAsrModelManager extends Mock implements OnDeviceAsrModelManager {}
class MockOfflineRecognizer extends Mock implements OfflineRecognizer {}
class MockOfflineStream extends Mock implements OfflineStream {}
class MockOfflineRecognizerResult extends Mock implements OfflineRecognizerResult {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SherpaOnnxAsrService service;
  late MockOnDeviceAsrModelManager mockManager;
  late MockOfflineRecognizer mockRecognizer;

  setUpAll(() {
    registerFallbackValue(Uint8List(0));
    registerFallbackValue(Float32List(0));
  });

  setUp(() {
    mockManager = MockOnDeviceAsrModelManager();
    mockRecognizer = MockOfflineRecognizer();
    service = SherpaOnnxAsrService(manager: mockManager);

    SharedPreferences.setMockInitialValues({});

    // Default mocks for initialize
    when(() => mockManager.initialize()).thenAnswer((_) async {});
    when(() => mockManager.manifest).thenReturn(const AsrModelManifest(models: [
      AsrModelEntry(
        key: 'sense-voice-small',
        name: 'SenseVoice',
        language: 'es',
        type: 'sense_voice',
        files: [
          AsrFileMeta(url: 'model.onnx', md5: '', sizeBytes: 100),
          AsrFileMeta(url: 'tokens.txt', md5: '', sizeBytes: 10),
        ],
      )
    ]));
  });

  group('SherpaOnnxAsrService Initialization', () {
    test('initialize sets state to unavailable if model not installed', () async {
      when(() => mockManager.isInstalled(any())).thenAnswer((_) async => false);

      await service.initialize();

      expect(service.state, AsrState.unavailable);
    });

    test('initialize transition states correctly', () async {
      final states = <AsrState>[];
      final subscription = service.stateStream.listen(states.add);

      when(() => mockManager.isInstalled(any())).thenAnswer((_) async => false);

      await service.initialize();

      // Give the stream a moment to emit all events
      await Future.delayed(Duration.zero);

      expect(states, containsAllInOrder([AsrState.initializing, AsrState.unavailable]));
      await subscription.cancel();
    });
  });

  group('SherpaOnnxAsrService Transcription', () {
    test('transcribe automatically initializes if not ready', () async {
      when(() => mockManager.isInstalled(any())).thenAnswer((_) async => false);

      expect(
        () => service.transcribe(Uint8List(0)),
        throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('ASR service not ready'))),
      );

      verify(() => mockManager.initialize()).called(1);
    });

    test('transcribe handles successful transcription', () async {
      service.recognizer = mockRecognizer;

      when(() => mockManager.isInstalled(any())).thenAnswer((_) async => true);
      when(() => mockManager.getLocalPath(any(), 'model.onnx')).thenAnswer((_) async => 'path/to/model.onnx');
      when(() => mockManager.getLocalPath(any(), 'tokens.txt')).thenAnswer((_) async => 'path/to/tokens.txt');

      final mockStream = MockOfflineStream();
      final mockResult = MockOfflineRecognizerResult();
      when(() => mockResult.text).thenReturn('Hola');
      when(() => mockRecognizer.createStream()).thenReturn(mockStream);
      when(() => mockRecognizer.getResult(mockStream)).thenReturn(mockResult);
      when(() => mockRecognizer.decode(mockStream)).thenReturn(null);
      when(() => mockStream.acceptWaveform(samples: any(named: 'samples'), sampleRate: any(named: 'sampleRate'))).thenReturn(null);
      when(() => mockStream.free()).thenReturn(null);

      // We need to bypass the actual initialize() call to native OfflineRecognizer
      // One way is to make sure service.state is already AsrState.ready
      // Since state is private-ish (getter only in interface, but public in impl), we can't set it easily.
      // But wait, the impl has 'AsrState state = AsrState.uninitialized;'. It's public.

      service.state = AsrState.ready;

      final result = await service.transcribe(Uint8List(44 + 2)); // Some dummy data with RIFF header space

      expect(result, 'Hola');
      expect(service.state, AsrState.ready);
      verify(() => mockRecognizer.createStream()).called(1);
    });

    test('transcribe handles errors', () async {
      service.recognizer = mockRecognizer;
      service.state = AsrState.ready;

      when(() => mockRecognizer.createStream()).thenThrow(Exception('Native error'));

      expect(
        () => service.transcribe(Uint8List(0)),
        throwsA(isA<Exception>()),
      );
      expect(service.state, AsrState.error);
    });
  });

  test('stop updates state from transcribing to ready', () async {
    service.state = AsrState.transcribing;
    await service.stop();
    expect(service.state, AsrState.ready);
  });

  test('dispose closes controllers', () {
    service.dispose();
    expect(service.stateStream, emitsDone);
    expect(service.errorStream, emitsDone);
  });
}
