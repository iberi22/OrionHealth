import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/settings/domain/services/device_capability_service.dart';

void main() {
  late DeviceCapabilityService service;

  setUp(() {
    service = DeviceCapabilityService();
  });

  group('DeviceCapability', () {
    test('tierLabel returns correct Spanish strings', () {
      const low = DeviceCapability(
        tier: DeviceCapabilityTier.low,
        totalMemoryMb: 1024,
        availableMemoryMb: 512,
        processorCount: 2,
        supportsGeminiCloud: true,
        recommendedModel: 'm1',
      );
      const medium = DeviceCapability(
        tier: DeviceCapabilityTier.medium,
        totalMemoryMb: 4096,
        availableMemoryMb: 2048,
        processorCount: 4,
        supportsGeminiCloud: true,
        recommendedModel: 'm2',
      );
      const high = DeviceCapability(
        tier: DeviceCapabilityTier.high,
        totalMemoryMb: 8192,
        availableMemoryMb: 4096,
        processorCount: 8,
        supportsGeminiCloud: true,
        recommendedModel: 'm3',
      );

      expect(low.tierLabel, 'Baja');
      expect(medium.tierLabel, 'Media');
      expect(high.tierLabel, 'Alta');
    });

    test('tierEmoji returns correct emojis', () {
      const low = DeviceCapability(
        tier: DeviceCapabilityTier.low,
        totalMemoryMb: 1, availableMemoryMb: 1, processorCount: 1,
        supportsGeminiCloud: true, recommendedModel: 'm',
      );
      const medium = DeviceCapability(
        tier: DeviceCapabilityTier.medium,
        totalMemoryMb: 1, availableMemoryMb: 1, processorCount: 1,
        supportsGeminiCloud: true, recommendedModel: 'm',
      );
      const high = DeviceCapability(
        tier: DeviceCapabilityTier.high,
        totalMemoryMb: 1, availableMemoryMb: 1, processorCount: 1,
        supportsGeminiCloud: true, recommendedModel: 'm',
      );

      expect(low.tierEmoji, '📱');
      expect(medium.tierEmoji, '💻');
      expect(high.tierEmoji, '🚀');
    });
  });

  group('LocalModelDefinition', () {
    test('minRamMb parses GB correctly', () {
      const def = LocalModelDefinition(id: 'id', name: 'name', size: 'size', minRam: '2GB');
      expect(def.minRamMb, 2048);
    });

    test('minRamMb parses MB correctly', () {
      const def = LocalModelDefinition(id: 'id', name: 'name', size: 'size', minRam: '500MB');
      expect(def.minRamMb, 500);
    });

    test('minRamMb handles invalid strings gracefully', () {
      const def = LocalModelDefinition(id: 'id', name: 'name', size: 'size', minRam: 'invalid');
      expect(def.minRamMb, 0);
    });
  });

  group('DeviceCapabilityService', () {
    test('detectCapability returns a local model instead of cloud', () async {
      final capability = await service.detectCapability();

      final cloudModels = [
        'gemini-2.5-flash',
        'gemini-2.0-flash',
        'gemini-2.0-flash-lite',
      ];

      expect(cloudModels.contains(capability.recommendedModel), isFalse);

      final localModelIds = availableLocalModelDefs.map((m) => m.id).toList();
      expect(localModelIds.contains(capability.recommendedModel), isTrue);
    });

    test('getBadgeColor returns correct strings for each tier', () {
      expect(DeviceCapabilityService.getBadgeColor(DeviceCapabilityTier.low), contains('Baja capacidad'));
      expect(DeviceCapabilityService.getBadgeColor(DeviceCapabilityTier.medium), contains('Capacidad media'));
      expect(DeviceCapabilityService.getBadgeColor(DeviceCapabilityTier.high), contains('Alta capacidad'));
    });

    test('canRunModel returns correct boolean based on RAM requirements', () {
      // availableLocalModelDefs has:
      // smolLM-135m: 1GB (1024MB)
      // phi-4-mini: 6GB (6144MB)

      // In tests Platform.isAndroid fallback or local detection might apply.
      // But DeviceCapabilityService._getTotalMemoryMb() might return 4096 or 8192 depending on environment.

      // If we can't easily mock Platform, we can at least test known models.
      expect(service.canRunModel('invalid-id'), isFalse);

      // We don't strictly know the environment's RAM, but we can verify consistency
      final canRunSmall = service.canRunModel('smolLM-135m');
      final canRunLarge = service.canRunModel('phi-4-mini');

      if (canRunLarge) {
        expect(canRunSmall, isTrue);
      }
    });

    test('getRecommendedLocalModel returns a valid model id or null', () {
      final recommended = service.getRecommendedLocalModel();
      if (recommended != null) {
        expect(availableLocalModelDefs.any((m) => m.id == recommended), isTrue);
      }
    });
  });
}
