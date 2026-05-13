import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/settings/domain/services/device_capability_service.dart';

void main() {
  late DeviceCapabilityService service;

  setUp(() {
    service = DeviceCapabilityService();
  });

  group('DeviceCapabilityService', () {
    test('detectCapability returns a local model instead of cloud', () async {
      final capability = await service.detectCapability();

      // Known cloud models that should NOT be returned
      final cloudModels = [
        'gemini-2.5-flash',
        'gemini-2.0-flash',
        'gemini-2.0-flash-lite',
      ];

      expect(
        cloudModels.contains(capability.recommendedModel),
        isFalse,
        reason: 'Should not recommend cloud model ${capability.recommendedModel}'
      );

      // Should be one of the local models
      final localModelIds = availableLocalModelDefs.map((m) => m.id).toList();
      expect(
        localModelIds.contains(capability.recommendedModel),
        isTrue,
        reason: 'Should recommend a local model, but got ${capability.recommendedModel}'
      );
    });
  });
}
