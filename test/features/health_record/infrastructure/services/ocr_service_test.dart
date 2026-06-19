import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/health_record/infrastructure/services/ocr_service.dart';
import 'package:path/path.dart' as p;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MlKitOcrService service;
  late String tempFile;

  setUp(() async {
    service = MlKitOcrService();
    tempFile = p.join(Directory.systemTemp.path, 'test_ocr.jpg');
    await File(tempFile).writeAsBytes([0, 0, 0]);

    const MethodChannel channel = MethodChannel('google_mlkit_text_recognizer');

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == 'vision#startTextRecognizer') {
        return {
          'text': 'Recognized OCR Text',
          'blocks': [],
        };
      }
      if (methodCall.method == 'vision#closeTextRecognizer') {
        return null;
      }
      return null;
    });
  });

  tearDown(() async {
    if (await File(tempFile).exists()) {
      await File(tempFile).delete();
    }
  });

  group('MlKitOcrService', () {
    test('extractText returns recognized text', () async {
      final result = await service.extractText(tempFile);
      expect(result, 'Recognized OCR Text');
    });

    test('extractText throws FileSystemException if file does not exist', () async {
      expect(
        () => service.extractText('non_existent.jpg'),
        throwsA(isA<FileSystemException>()),
      );
    });
  });
}
