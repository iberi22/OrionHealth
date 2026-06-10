import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:orionhealth_health/features/settings/application/llm_settings_cubit.dart';
import 'package:orionhealth_health/features/settings/domain/entities/llm_config.dart';
import 'package:orionhealth_health/features/settings/domain/services/device_capability_service.dart';
import 'package:orionhealth_health/features/settings/presentation/pages/llm_settings_page.dart';
import 'package:orionhealth_health/l10n/app_localizations.dart';
import 'package:orionhealth_health/core/theme/app_theme.dart';

class MockLlmSettingsCubit extends Mock implements LlmSettingsCubit {}

void main() {
  late MockLlmSettingsCubit mockCubit;
  final getIt = GetIt.instance;

  setUpAll(() {
    mockCubit = MockLlmSettingsCubit();
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
      deviceCapability: deviceCapability,
      installedModels: const {'smolLM-135m'},
    ));
    when(() => mockCubit.loadSettings()).thenAnswer((_) async {});
    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
  });

  testWidgets('Settings Page - Local Tab Golden', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920); // Using larger size for Settings to avoid overflows
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('es'),
        home: const LlmSettingsPage(),
      ),
    );

    await tester.pumpAndSettle();

    await expectLater(
      find.byType(LlmSettingsPage),
      matchesGoldenFile('goldens/settings_page_local.png'),
    );

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });

  testWidgets('Settings Page - Cloud Tab Golden', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('es'),
        home: const LlmSettingsPage(),
      ),
    );

    await tester.pumpAndSettle();

    // Switch to Cloud tab
    await tester.tap(find.byIcon(Icons.cloud));
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(LlmSettingsPage),
      matchesGoldenFile('goldens/settings_page_cloud.png'),
    );

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });

  testWidgets('Settings Page - Mode Tab Golden', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('es'),
        home: const LlmSettingsPage(),
      ),
    );

    await tester.pumpAndSettle();

    // Switch to Mode tab
    await tester.tap(find.byIcon(Icons.tune));
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(LlmSettingsPage),
      matchesGoldenFile('goldens/settings_page_mode.png'),
    );

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
