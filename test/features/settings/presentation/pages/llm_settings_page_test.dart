import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/local_agent/domain/services/llm_adapter.dart';
import 'package:orionhealth_health/features/settings/application/llm_settings_cubit.dart';
import 'package:orionhealth_health/features/settings/domain/entities/llm_config.dart';
import 'package:orionhealth_health/features/settings/domain/services/device_capability_service.dart';
import 'package:orionhealth_health/features/settings/presentation/pages/llm_settings_page.dart';

class MockLlmSettingsCubit extends Mock implements LlmSettingsCubit {}
class MockLlmAdapter extends Mock implements LlmAdapter {}

void main() {
  late MockLlmSettingsCubit mockCubit;
  late MockLlmAdapter mockLlmAdapter;

  final testConfig = LlmConfig(
    selectedModel: 'gemini-2.0-flash',
    localModelId: 'gemma-3-270m',
  );

  const testCapability = DeviceCapability(
    tier: DeviceCapabilityTier.medium,
    totalMemoryMb: 4096,
    availableMemoryMb: 2048,
    processorCount: 8,
    supportsGeminiCloud: true,
    recommendedModel: 'gemini-2.0-flash',
  );

  setUp(() {
    mockCubit = MockLlmSettingsCubit();
    mockLlmAdapter = MockLlmAdapter();

    GetIt.I.registerSingleton<LlmSettingsCubit>(mockCubit);
    GetIt.I.registerSingleton<LlmAdapter>(mockLlmAdapter, instanceName: 'gemma');

    when(() => mockCubit.loadSettings()).thenAnswer((_) async {});
    when(() => mockCubit.close()).thenAnswer((_) async {});
    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
  });

  tearDown(() {
    GetIt.I.reset();
  });

  Widget createWidget() {
    return MaterialApp(
      home: const LlmSettingsPage(),
    );
  }

  group('LlmSettingsPage', () {
    testWidgets('renders loading state', (tester) async {
      when(() => mockCubit.state).thenReturn(const LlmSettingsLoading());

      await tester.pumpWidget(createWidget());
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders error state', (tester) async {
      when(() => mockCubit.state).thenReturn(const LlmSettingsError('Error message'));

      await tester.pumpWidget(createWidget());
      expect(find.textContaining('Error: Error message'), findsOneWidget);
    });

    testWidgets('renders loaded state with tabs', (tester) async {
      when(() => mockCubit.state).thenReturn(LlmSettingsLoaded(
        config: testConfig,
        deviceCapability: testCapability,
      ));

      await tester.pumpWidget(createWidget());

      expect(find.text('LOCAL'), findsOneWidget);
      expect(find.text('CLOUD'), findsOneWidget);
      expect(find.text('MODO'), findsOneWidget);

      // Default tab is LOCAL
      expect(find.text('Capacidad del Dispositivo'), findsOneWidget);
    });

    testWidgets('clicking Descargar calls cubit', (tester) async {
      when(() => mockCubit.state).thenReturn(LlmSettingsLoaded(
        config: testConfig,
        deviceCapability: testCapability,
      ));
      when(() => mockCubit.downloadModel(any())).thenAnswer((_) async {});

      await tester.pumpWidget(createWidget());

      final downloadButton = find.text('Descargar').first;
      await tester.tap(downloadButton);
      await tester.pump();

      verify(() => mockCubit.downloadModel(any())).called(1);
    });

    testWidgets('switching to MODO tab and toggling cloud switch calls cubit', (tester) async {
      when(() => mockCubit.state).thenReturn(LlmSettingsLoaded(
        config: testConfig,
        deviceCapability: testCapability,
      ));
      when(() => mockCubit.updateAllowCloudApiCalls(any())).thenAnswer((_) async {});

      await tester.pumpWidget(createWidget());

      await tester.tap(find.text('MODO'));
      await tester.pumpAndSettle();

      final switchFinder = find.byType(Switch);
      expect(switchFinder, findsOneWidget);

      await tester.tap(switchFinder);
      await tester.pump();

      verify(() => mockCubit.updateAllowCloudApiCalls(any())).called(1);
    });
  });
}
