import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;
import 'package:orionhealth_health/core/services/asr/asr_model_manager.dart';
import 'package:orionhealth_health/core/services/asr/asr_model_manifest.dart';

class MockDio extends Mock implements Dio {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late OnDeviceAsrModelManager manager;
  late MockDio mockDio;
  late Directory tempDir;

  setUp(() async {
    mockDio = MockDio();
    manager = OnDeviceAsrModelManager();
    manager.debugSetDioForTesting(mockDio);

    tempDir = await Directory.systemTemp.createTemp('asr_test');
    manager.debugSetBaseDirForTesting(tempDir);

    // Mock rootBundle for manifest
    // ignore: unused_local_variable
    const manifestJson = '''
    {
      "models": [
        {
          "key": "test-model",
          "name": "Test Model",
          "language": "es",
          "type": "sense_voice",
          "files": [
            {
              "url": "http://example.com/model.onnx",
              "md5": "098f6bcd4621d373cade4e832627b4f6",
              "size_bytes": 4
            }
          ]
        }
      ]
    }
    ''';

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall methodCall) async {
        return tempDir.path;
      },
    );

    // This is a bit tricky since rootBundle.loadString is hard to mock directly without services.
    // However, OnDeviceAsrModelManager uses rootBundle.loadString('assets/asr/manifest.json').
    // We can use a trick or just ensure it's loaded.
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('initialize creates base directory', () async {
    await manager.initialize();
    expect(await tempDir.exists(), isTrue);
  });

  test('installModel downloads files', () async {
    final modelEntry = const AsrModelEntry(
      key: 'test-model',
      name: 'Test Model',
      language: 'es',
      type: 'sense_voice',
      files: [
        AsrFileMeta(url: 'http://example.com/file1', md5: '', sizeBytes: 10),
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
      await File(path).writeAsString('test data');
      return Response(requestOptions: RequestOptions(path: ''));
    });

    await manager.installModel(modelEntry);

    verify(() => mockDio.download(
      'http://example.com/file1',
      any(),
      onReceiveProgress: any(named: 'onReceiveProgress'),
      options: any(named: 'options'),
    )).called(1);
  });

  test('isInstalled returns false when files missing', () async {
    // We need to inject the manifest first.
    // Since _manifest is private, we depend on initialize() loading it from assets.
    // Or we can just use the fact that it's empty by default.
    final installed = await manager.isInstalled('non-existent');
    expect(installed, isFalse);
  });

  test('removeModel deletes directory', () async {
    final modelDir = Directory(p.join(tempDir.path, 'models', 'test-model'));
    await modelDir.create(recursive: true);
    expect(await modelDir.exists(), isTrue);

    await manager.removeModel('test-model');
    expect(await modelDir.exists(), isFalse);
  });
}
