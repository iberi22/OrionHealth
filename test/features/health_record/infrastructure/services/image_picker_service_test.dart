import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/health_record/infrastructure/services/image_picker_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late ImagePickerServiceImpl service;
  final List<MethodCall> log = <MethodCall>[];

  setUp(() {
    service = ImagePickerServiceImpl();
    log.clear();

    const MethodChannel channel = MethodChannel('plugins.flutter.io/image_picker');

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      log.add(methodCall);
      if (methodCall.method == 'pickImage') {
        return 'test_image.jpg';
      }
      return null;
    });
  });

  group('ImagePickerServiceImpl', () {
    test('pickImageFromCamera returns path when image is picked', () async {
      final result = await service.pickImageFromCamera();
      expect(result, 'test_image.jpg');
      expect(log.first.method, 'pickImage');
      expect(log.first.arguments['source'], 0); // 0 is camera in ImageSource enum typically
    });

    test('pickImageFromGallery returns path when image is picked', () async {
      final result = await service.pickImageFromGallery();
      expect(result, 'test_image.jpg');
      expect(log.first.method, 'pickImage');
      expect(log.first.arguments['source'], 1); // 1 is gallery
    });

    test('returns null when picking is cancelled', () async {
      const MethodChannel channel = MethodChannel('plugins.flutter.io/image_picker');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        return null;
      });

      final result = await service.pickImageFromCamera();
      expect(result, isNull);
    });
  });
}
