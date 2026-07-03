import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:orionhealth_health/features/health_data_import/presentation/pages/health_import_page.dart';
import 'package:orionhealth_health/features/health_data_import/application/health_import_cubit.dart';
import 'package:orionhealth_health/features/health_data_import/application/health_import_state.dart';
import 'package:orionhealth_health/features/health_data_import/domain/entities/health_data_source.dart';
import '../../../../core/golden_test_utils.dart';

class MockHealthImportCubit extends Mock implements HealthImportCubit {}

void main() {
  late MockHealthImportCubit mockCubit;

  setUpAll(() {
    initializeDateFormatting('es', null);
    registerFallbackValue(HealthDataSource.googleFit);
  });

  setUp(() async {
    mockCubit = MockHealthImportCubit();
    await GetIt.I.reset();
    GetIt.I.registerSingleton<HealthImportCubit>(mockCubit);

    when(() => mockCubit.checkAvailableSources()).thenAnswer((_) async {});
    when(() => mockCubit.close()).thenAnswer((_) async {});
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  group('Health Import Page Golden Tests', () {
    testWidgets('Health Import Page - Ready State', (tester) async {
      setupGoldenTest(tester);

      final state = HealthImportReady(
        availableSources: HealthDataSource.values,
        availability: {
          HealthDataSource.googleFit: true,
          HealthDataSource.appleHealth: false,
          HealthDataSource.samsungHealth: true,
        },
      );

      when(() => mockCubit.state).thenReturn(state);
      when(() => mockCubit.stream).thenAnswer((_) => Stream.fromIterable([state]));

      await tester.pumpWidget(wrapWithMaterial(const HealthImportPage()));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(HealthImportPage),
        matchesGoldenFile("../../../../../golden/reference/health_import_page_ready.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('Health Import Page - Importing State', (tester) async {
      setupGoldenTest(tester);

      const state = HealthImportImporting(
        source: HealthDataSource.googleFit,
        currentStep: 'Importando pasos...',
        totalSteps: 5,
        currentStepNum: 2,
        importedCount: 150,
      );

      when(() => mockCubit.state).thenReturn(state);
      when(() => mockCubit.stream).thenAnswer((_) => Stream.fromIterable([state]));

      await tester.pumpWidget(wrapWithMaterial(const HealthImportPage()));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(HealthImportPage),
        matchesGoldenFile("../../../../../golden/reference/health_import_page_importing.png"),
      );
      resetGoldenTest(tester);
    });
  });
}
