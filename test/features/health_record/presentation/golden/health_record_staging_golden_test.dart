import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:orionhealth_health/features/health_record/presentation/pages/health_record_staging_page.dart';
import 'package:orionhealth_health/features/health_record/application/bloc/health_record_cubit.dart';
import 'package:orionhealth_health/features/health_record/domain/entities/medical_record.dart';
import 'package:orionhealth_health/features/health_record/domain/repositories/health_record_repository.dart';
import 'package:health_wallet/health_wallet.dart';
import '../../../../core/golden_test_utils.dart';

class MockHealthRecordCubit extends Mock implements HealthRecordCubit {}
class MockHealthRecordRepository extends Mock implements HealthRecordRepository {}
class MockWalletService extends Mock implements WalletService {}

void main() {
  late MockHealthRecordCubit mockCubit;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    mockCubit = MockHealthRecordCubit();

    await GetIt.I.reset();
    GetIt.I.registerSingleton<HealthRecordCubit>(mockCubit);
    GetIt.I.registerSingleton<HealthRecordRepository>(MockHealthRecordRepository());
    GetIt.I.registerSingleton<WalletService>(MockWalletService());
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  Widget buildTestWidget() {
    return BlocProvider<HealthRecordCubit>.value(
      value: mockCubit,
      child: wrapWithMaterial(const HealthRecordStagingPage()),
    );
  }

  group('HealthRecordStagingPage Golden Tests', () {
    testWidgets('HealthRecordStagingPage - History View', (tester) async {
      setupGoldenTest(tester);

      final records = [
        MedicalRecord(
          date: DateTime(2023, 10, 1),
          type: RecordType.clinicalNote,
          summary: 'Consulta General - Gripa',
        ),
        MedicalRecord(
          date: DateTime(2023, 9, 15),
          type: RecordType.labResult,
          summary: 'Examen de Sangre',
        ),
      ];

      when(() => mockCubit.state).thenReturn(HealthRecordLoaded(records));
      when(() => mockCubit.loadRecords()).thenAnswer((_) async => {});
      when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
      when(() => mockCubit.close()).thenAnswer((_) async => {});

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(HealthRecordStagingPage),
        matchesGoldenFile("goldens/health_record_staging_history.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('HealthRecordStagingPage - File Picked (Form)', (tester) async {
      setupGoldenTest(tester);

      when(() => mockCubit.state).thenReturn(const HealthRecordFilePicked(
        filePath: 'test.pdf',
        extractedText: 'Extracted text here',
      ));
      when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
      when(() => mockCubit.close()).thenAnswer((_) async => {});

      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      await expectLater(
        find.byType(HealthRecordStagingPage),
        matchesGoldenFile("goldens/health_record_staging_form.png"),
      );
      resetGoldenTest(tester);
    });
  });
}
