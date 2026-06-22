import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;
import 'package:orionhealth_health/core/services/tts/model_manager.dart';
import 'package:orionhealth_health/core/services/tts/model_manifest.dart';

class MockDio extends Mock implements Dio {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late OnDeviceTTSModelManager manager;
  late MockDio mockDio;
  late Directory tempDir;

  setUp(() async {
    mockDio = MockDio();
    manager = OnDeviceTTSModelManager();
    manager.debugSetDioForTesting(mockDio);

    tempDir = await Directory.systemTemp.createTemp('tts_test');
    manager.debugSetBaseDirForTesting(tempDir);
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('setManifest persists manifest to file', () async {
    final manifest = const TTSModelManifest(voices: [
      VoiceEntry(key: 'v1', language: 'en', quality: 'high', files: [])
    ]);

    await manager.setManifest(manifest);

    final file = File(p.join(tempDir.path, 'manifest.json'));
    expect(await file.exists(), isTrue);
    expect(manager.manifest.voices, hasLength(1));
  });

  test('installVoice downloads files', () async {
    final voiceEntry = const VoiceEntry(
      key: 'test-voice',
      language: 'es',
      quality: 'low',
      files: [
        VoiceFileMeta(url: 'http://example.com/v.onnx', md5: '', sizeBytes: 10),
      ],
    );

    when(() => mockDio.download(
      any(),
      any(),
      onReceiveProgress: any(named: 'onReceiveProgress'),
      options: any(named: 'options'),
    )).thenAnswer((invocation) async {
      final path = invocation.positionalArguments[1] as String;
      await File(path).create(recursive: true);
      return Response(requestOptions: RequestOptions(path: ''));
    });

    await manager.installVoice(voiceEntry);

    verify(() => mockDio.download(
      'http://example.com/v.onnx',
      any(),
      onReceiveProgress: any(named: 'onReceiveProgress'),
      options: any(named: 'options'),
    )).called(1);
  });

  test('listInstalled returns list of model keys', () async {
    final modelsDir = Directory(p.join(tempDir.path, 'models'));
    await Directory(p.join(modelsDir.path, 'voice1')).create(recursive: true);
    await Directory(p.join(modelsDir.path, 'voice2')).create(recursive: true);

    final installed = await manager.listInstalled();
    expect(installed, containsAll(['voice1', 'voice2']));
  });
}
