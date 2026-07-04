import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/core/di/injection.dart';
import 'package:orionhealth_health/features/health_record/application/bloc/health_record_cubit.dart';
import 'package:orionhealth_health/features/health_record/domain/entities/medical_record.dart';
import 'package:orionhealth_health/features/health_record/presentation/pages/health_record_staging_page.dart';
import '../../../../core/golden_test_utils.dart';
import 'health_record_mocks.dart';

void main() {
  late MockHealthRecordCubit mockCubit;

  setUp(() async {
    mockCubit = MockHealthRecordCubit();
    await getIt.reset();
    getIt.registerFactory<HealthRecordCubit>(() => mockCubit);
  });

  tearDown(() async {
    await getIt.reset();
  });

  Widget wrapWithCubit(Widget child) {
    return wrapWithMaterial(child);
  }

  testWidgets('HealthRecordStagingPage initial empty state golden test', (tester) async {
    setupGoldenTest(tester);

    when(() => mockCubit.state).thenReturn(const HealthRecordInitial());
    when(() => mockCubit.loadRecords()).thenAnswer((_) async {});
    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockCubit.close()).thenAnswer((_) async {});

    await tester.pumpWidget(wrapWithCubit(const HealthRecordStagingPage()));
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(HealthRecordStagingPage),
      matchesGoldenFile('goldens/staging_page_empty.png'),
    );
  });

  testWidgets('HealthRecordStagingPage loaded state golden test', (tester) async {
    setupGoldenTest(tester);

    final records = [
      MedicalRecord(
        date: DateTime(2024, 7, 4),
        type: RecordType.clinicalNote,
        summary: 'Nota de seguimiento trimestral',
      ),
      MedicalRecord(
        date: DateTime(2024, 6, 15),
        type: RecordType.prescription,
        summary: 'Receta para hipertensión',
      ),
    ];

    when(() => mockCubit.state).thenReturn(HealthRecordLoaded(records));
    when(() => mockCubit.loadRecords()).thenAnswer((_) async {});
    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockCubit.close()).thenAnswer((_) async {});

    await tester.pumpWidget(wrapWithCubit(const HealthRecordStagingPage()));
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(HealthRecordStagingPage),
      matchesGoldenFile('goldens/staging_page_loaded.png'),
    );
  });

  testWidgets('HealthRecordStagingPage loading state golden test', (tester) async {
    setupGoldenTest(tester);

    when(() => mockCubit.state).thenReturn(const HealthRecordLoading());
    when(() => mockCubit.loadRecords()).thenAnswer((_) async {});
    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockCubit.close()).thenAnswer((_) async {});

    await tester.pumpWidget(wrapWithCubit(const HealthRecordStagingPage()));
    // Don't use pumpAndSettle because CircularProgressIndicator animates infinitely
    await tester.pump(const Duration(milliseconds: 100));

    await expectLater(
      find.byType(HealthRecordStagingPage),
      matchesGoldenFile('goldens/staging_page_loading.png'),
    );
  });

  testWidgets('HealthRecordStagingPage file picked (form) state golden test', (tester) async {
    setupGoldenTest(tester);

    when(() => mockCubit.state).thenReturn(const HealthRecordFilePicked(
      filePath: '/path/to/medical_report.pdf',
      extractedText: 'RESULTADOS DE LABORATORIO\nGlucosa: 95 mg/dL\nColesterol: 180 mg/dL',
    ));
    when(() => mockCubit.loadRecords()).thenAnswer((_) async {});
    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockCubit.close()).thenAnswer((_) async {});

    await tester.pumpWidget(wrapWithCubit(const HealthRecordStagingPage()));
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(HealthRecordStagingPage),
      matchesGoldenFile('goldens/staging_page_form.png'),
    );
  });
}
