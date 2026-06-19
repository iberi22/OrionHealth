import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/settings/application/llm_settings_cubit.dart';
import 'package:orionhealth_health/features/settings/domain/entities/app_settings.dart';
import 'package:orionhealth_health/features/settings/domain/entities/llm_config.dart';
import 'package:orionhealth_health/features/settings/domain/services/device_capability_service.dart';

void main() {
  group('LlmSettingsState', () {
    final testConfig = LlmConfig(selectedModel: 'test-model');
    final testAppSettings = AppSettings();
    const testCapability = DeviceCapability(
      tier: DeviceCapabilityTier.medium,
      totalMemoryMb: 4096,
      availableMemoryMb: 2048,
      processorCount: 4,
      supportsGeminiCloud: true,
      recommendedModel: 'gemini-2.0-flash',
    );

    test('LlmSettingsLoaded supports equality', () {
      final state1 = LlmSettingsLoaded(
        config: testConfig,
        appSettings: testAppSettings,
        deviceCapability: testCapability,
        downloadProgress: const {'model1': 0.5},
      );
      final state2 = LlmSettingsLoaded(
        config: testConfig,
        appSettings: testAppSettings,
        deviceCapability: testCapability,
        downloadProgress: const {'model1': 0.5},
      );

      expect(state1, equals(state2));
    });

    test('LlmSettingsLoaded copyWith should update fields', () {
      final state = LlmSettingsLoaded(
        config: testConfig,
        appSettings: testAppSettings,
        deviceCapability: testCapability,
      );

      final updated = state.copyWith(
        connectionVerified: true,
        connectionError: 'error',
      );

      expect(updated.connectionVerified, true);
      expect(updated.connectionError, 'error');
      expect(updated.config, testConfig);
    });

    test('LlmSettingsError supports equality', () {
      expect(
        const LlmSettingsError('error'),
        equals(const LlmSettingsError('error')),
      );
    });
  });
}
