import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:record/record.dart';
import 'package:orionhealth_health/core/services/audio/audio_recorder_service.dart';

class MockAudioRecorder extends Mock implements AudioRecorder {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AudioRecorderService recorderService;
  late MockAudioRecorder mockRecorder;

  setUpAll(() {
    registerFallbackValue(const RecordConfig());
  });

  setUp(() {
    mockRecorder = MockAudioRecorder();
    recorderService = AudioRecorderService(recorder: mockRecorder);

    when(() => mockRecorder.hasPermission()).thenAnswer((_) async => true);
    when(() => mockRecorder.start(any(), path: any(named: 'path'))).thenAnswer((_) async => null);
    when(() => mockRecorder.stop()).thenAnswer((_) async => null);
    when(() => mockRecorder.dispose()).thenAnswer((_) async => null);

    // Mock permission handler channel
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('flutter.baseflow.com/permissions/methods'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'checkPermissionStatus') {
          return 1; // granted
        }
        if (methodCall.method == 'requestPermission') {
          return {1: 1}; // granted
        }
        return null;
      },
    );
  });

  test('startRecording starts recorder when permission is granted', () async {
    await recorderService.startRecording();

    verify(() => mockRecorder.hasPermission()).called(1);
    verify(() => mockRecorder.start(any(), path: any(named: 'path'))).called(1);
    expect(recorderService.isRecording, isTrue);
  });

  test('stopRecording stops recorder and returns bytes', () async {
    await recorderService.startRecording();

    final tempFile = File('${Directory.systemTemp.path}/test_audio.wav');
    await tempFile.writeAsBytes(Uint8List.fromList([10, 20, 30]));

    when(() => mockRecorder.stop()).thenAnswer((_) async => tempFile.path);

    final bytes = await recorderService.stopRecording();

    expect(bytes, isNotNull);
    expect(bytes, Uint8List.fromList([10, 20, 30]));
    expect(recorderService.isRecording, isFalse);
    expect(await tempFile.exists(), isFalse);
  });

  test('duration stream emits values during recording', () async {
    await recorderService.startRecording();

    final duration = await recorderService.recordingDurationStream.first;
    expect(duration, isNotNull);
  });

  test('volume streams emit values during recording', () async {
    await recorderService.startRecording();

    final volume = await recorderService.currentVolumeStream.first;
    expect(volume, isNotNull);
    expect(volume, greaterThanOrEqualTo(0.0));
    expect(volume, lessThanOrEqualTo(1.0));

    final levels = await recorderService.volumeLevelsStream.first;
    expect(levels, isNotEmpty);
    expect(levels.length, 8);
  });

  test('handle stopRecording with null path', () async {
    await recorderService.startRecording();
    when(() => mockRecorder.stop()).thenAnswer((_) async => null);

    final bytes = await recorderService.stopRecording();
    expect(bytes, isNull);
  });

  test('handle recording errors', () async {
    when(() => mockRecorder.start(any(), path: any(named: 'path'))).thenThrow(Exception('Record error'));

    final errorFuture = expectLater(recorderService.errorStream, emits(contains('Failed to start recording')));

    await recorderService.startRecording();
    await errorFuture;
  });
}
