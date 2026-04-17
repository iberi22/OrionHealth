import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/core/device/device_capability.dart';
import 'package:orionhealth_health/core/services/aicore_service.dart';

class MockAicoreService extends Mock implements AicoreService {}

void main() {
  late DeviceCapabilityService service;
  late MockAicoreService mockAicoreService;

  setUp(() {
    mockAicoreService = MockAicoreService();
    service = DeviceCapabilityService(mockAicoreService);
  });

  group('DeviceCapabilityService', () {
    test('detects light profile for < 4GB RAM', () async {
      when(() => mockAicoreService.getHardwareInfo()).thenAnswer((_) async => {
        'totalRam': (3 * 1024 * 1024 * 1024), // 3GB
        'supportedAbis': 'arm64-v8a',
      });

      final info = await service.getDeviceCapabilities();

      expect(info.profile, DeviceProfile.light);
      expect(info.recommendation, ModelRecommendation.model2B);
      expect(info.totalRamGb, closeTo(3.0, 0.01));
    });

    test('detects medium profile for 4-6GB RAM', () async {
      when(() => mockAicoreService.getHardwareInfo()).thenAnswer((_) async => {
        'totalRam': (5 * 1024 * 1024 * 1024), // 5GB
        'supportedAbis': 'arm64-v8a',
      });

      final info = await service.getDeviceCapabilities();

      expect(info.profile, DeviceProfile.medium);
      expect(info.recommendation, ModelRecommendation.model7B);
    });

    test('detects high-end profile for > 6GB RAM', () async {
      when(() => mockAicoreService.getHardwareInfo()).thenAnswer((_) async => {
        'totalRam': (8 * 1024 * 1024 * 1024), // 8GB
        'supportedAbis': 'arm64-v8a',
      });

      final info = await service.getDeviceCapabilities();

      expect(info.profile, DeviceProfile.highEnd);
      expect(info.recommendation, ModelRecommendation.model9B);
    });

    test('recommends 2B for 32-bit devices with medium RAM', () async {
      when(() => mockAicoreService.getHardwareInfo()).thenAnswer((_) async => {
        'totalRam': (5 * 1024 * 1024 * 1024), // 5GB
        'supportedAbis': 'armeabi-v7a',
      });

      final info = await service.getDeviceCapabilities();

      expect(info.profile, DeviceProfile.medium);
      expect(info.recommendation, ModelRecommendation.model2B);
    });
  });
}
