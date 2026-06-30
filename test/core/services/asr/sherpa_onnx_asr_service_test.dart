import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart';
import 'package:orionhealth_health/core/services/asr/sherpa_onnx_asr_service.dart';
import 'package:orionhealth_health/core/services/asr/asr_types.dart';

class MockOfflineRecognizer extends Mock implements OfflineRecognizer {}
class MockOfflineStream extends Mock implements OfflineStream {}

void main() {
  // SherpaOnnxAsrService is hard to test because it instantiates OfflineRecognizer
  // internally and uses static methods of sherpa_onnx.
  // I will skip complex mocks for now or add a factory if necessary.
  // Given the goal is coverage, I'll try to at least test initialization failure
  // which happens when no models are present.

  test('initialize fails when models not found', () async {
    // Mock path_provider channel to avoid MissingPluginException
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall methodCall) async {
        return '.';
      },
    );

    final service = SherpaOnnxAsrService();
    await service.initialize();
    // It returns error because of MissingPluginException or model missing
    expect(service.state, anyOf(AsrState.unavailable, AsrState.error));
  });
}
