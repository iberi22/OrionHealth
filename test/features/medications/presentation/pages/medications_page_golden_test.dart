import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:orionhealth_health/features/medications/application/medications_cubit.dart';
import 'package:orionhealth_health/features/medications/application/medications_state.dart';
import 'package:orionhealth_health/features/medications/domain/entities/medication.dart';
import 'package:orionhealth_health/features/medications/presentation/pages/medications_page.dart';
import 'package:orionhealth_health/l10n/app_localizations.dart';
import 'package:orionhealth_health/core/theme/app_theme.dart';

class MockMedicationsCubit extends Mock implements MedicationsCubit {}

void main() {
  late MockMedicationsCubit mockCubit;
  final getIt = GetIt.instance;

  setUpAll(() {
    mockCubit = MockMedicationsCubit();
    getIt.registerFactory<MedicationsCubit>(() => mockCubit);
  });

  setUp(() {
    when(() => mockCubit.loadMedications()).thenAnswer((_) async {});
    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockCubit.close()).thenAnswer((_) async {});
  });

  testWidgets('Medications Page - List Golden', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;

    final medications = [
      Medication(
        id: 1,
        name: 'Metformina',
        dosage: '500mg',
        frequency: '2 veces al día',
        startDate: DateTime(2023, 1, 1),
        isActive: true,
      ),
      Medication(
        id: 2,
        name: 'Atorvastatina',
        dosage: '20mg',
        frequency: '1 vez al día (noche)',
        startDate: DateTime(2023, 5, 10),
        isActive: true,
      ),
    ];

    when(() => mockCubit.state).thenReturn(MedicationsLoaded(medications));

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('es'),
        home: const MedicationsPage(),
      ),
    );

    await tester.pump();

    await expectLater(
      find.byType(MedicationsPage),
      matchesGoldenFile('goldens/medications_page_list.png'),
    );

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });

  testWidgets('Medications Page - Empty State Golden', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;

    when(() => mockCubit.state).thenReturn(const MedicationsLoaded([]));

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('es'),
        home: const MedicationsPage(),
      ),
    );

    await tester.pump();

    await expectLater(
      find.byType(MedicationsPage),
      matchesGoldenFile('goldens/medications_page_empty.png'),
    );

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
