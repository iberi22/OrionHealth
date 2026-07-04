import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:orionhealth_health/features/settings/application/llm_settings_cubit.dart';
import 'package:orionhealth_health/features/settings/domain/entities/app_settings.dart';
import 'package:orionhealth_health/features/settings/domain/entities/llm_config.dart';
import 'package:orionhealth_health/features/settings/domain/services/device_capability_service.dart';
import 'package:orionhealth_health/features/settings/presentation/pages/llm_settings_page.dart';
import 'package:orionhealth_health/core/di/injection.dart';

import '../../../../core/golden_test_utils.dart';

class MockLlmSettingsCubit extends Mock implements LlmSettingsCubit {}

void main() {
  late MockLlmSettingsCubit mockCubit;

  setUpAll(() {
    mockCubit = MockLlmSettingsCubit();
    // Register in getIt as LlmSettingsPage uses it
    getIt.allowReassignment = true;
    getIt.registerFactory<LlmSettingsCubit>(() => mockCubit);
  });

  setUp(() {
    final config = LlmConfig(
      selectedModel: 'gpt-4o',
      useCloudApi: true,
      allowCloudApiCalls: true,
      deviceCapabilityTier: 'high',
      recommendedModel: 'phi-4-mini',
      providerType: 'openai',
      apiKey: 'sk-mock-key',
      cloudModel: 'gpt-4o',
    );

    final appSettings = AppSettings(
      themeMode: 'dark',
      languageCode: 'es',
      notificationsEnabled: true,
    );

    final deviceCapability = const DeviceCapability(
      tier: DeviceCapabilityTier.high,
      totalMemoryMb: 8192,
      availableMemoryMb: 3276,
      processorCount: 8,
      supportsGeminiCloud: true,
      recommendedModel: 'phi-4-mini',
      hasGpu: true,
      os: 'android',
    );

    when(() => mockCubit.state).thenReturn(LlmSettingsLoaded(
      config: config,
      appSettings: appSettings,
      deviceCapability: deviceCapability,
      installedModels: const {'smolLM-135m'},
    ));
    when(() => mockCubit.loadSettings()).thenAnswer((_) async {});
    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockCubit.close()).thenAnswer((_) async {});
  });

  group('LlmSettingsPage Golden Tests', () {
    testWidgets('Local Tab', (WidgetTester tester) async {
      setupGoldenTest(tester, size: const Size(800, 1200));

      await tester.pumpWidget(
        wrapWithMaterial(const LlmSettingsPage()),
      );

      await tester.pumpAndSettle();

      await expectLater(
        find.byType(LlmSettingsPage),
        matchesGoldenFile('goldens/settings_page_local.png'),
      );
    });

    testWidgets('Cloud Tab', (WidgetTester tester) async {
      setupGoldenTest(tester, size: const Size(800, 1200));

      await tester.pumpWidget(
        wrapWithMaterial(const LlmSettingsPage()),
      );

      await tester.pumpAndSettle();

      // Switch to Cloud tab
      await tester.tap(find.byIcon(Icons.cloud));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(LlmSettingsPage),
        matchesGoldenFile('goldens/settings_page_cloud.png'),
      );
    });

    testWidgets('Mode Tab', (WidgetTester tester) async {
      setupGoldenTest(tester, size: const Size(800, 1200));

      await tester.pumpWidget(
        wrapWithMaterial(const LlmSettingsPage()),
      );

      await tester.pumpAndSettle();

      // Switch to Mode tab
      await tester.tap(find.byIcon(Icons.tune));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(LlmSettingsPage),
        matchesGoldenFile('goldens/settings_page_mode.png'),
      );
    });

    testWidgets('App Tab', (WidgetTester tester) async {
      setupGoldenTest(tester, size: const Size(800, 1200));

      await tester.pumpWidget(
        wrapWithMaterial(const LlmSettingsPage()),
      );

      await tester.pumpAndSettle();

      // Switch to App tab
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(LlmSettingsPage),
        matchesGoldenFile('goldens/settings_page_app.png'),
      );
    });

    testWidgets('Loading State', (WidgetTester tester) async {
      when(() => mockCubit.state).thenReturn(LlmSettingsLoading());
      setupGoldenTest(tester, size: const Size(800, 1200));

      await tester.pumpWidget(
        wrapWithMaterial(const LlmSettingsPage()),
      );

      await tester.pump(); // Just pump to show loader

      await expectLater(
        find.byType(LlmSettingsPage),
        matchesGoldenFile('goldens/settings_page_loading.png'),
      );
    });
  });
}
