import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:orionhealth_health/features/health_record/presentation/pages/upload_page.dart';
import 'package:orionhealth_health/features/health_record/presentation/pages/timeline_page.dart';
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
  late MockHealthRecordRepository mockRepo;
  late MockWalletService mockWalletService;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    mockCubit = MockHealthRecordCubit();
    mockRepo = MockHealthRecordRepository();
    mockWalletService = MockWalletService();

    await GetIt.I.reset();
    GetIt.I.registerSingleton<HealthRecordCubit>(mockCubit);
    GetIt.I.registerSingleton<HealthRecordRepository>(mockRepo);
    GetIt.I.registerSingleton<WalletService>(mockWalletService);
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  Widget buildTestWidget(Widget child) {
    return BlocProvider<HealthRecordCubit>.value(
      value: mockCubit,
      child: wrapWithMaterial(child),
    );
  }

  group('Health Record Upload & Timeline Golden Tests', () {
    testWidgets('UploadPage - Source Selection', (tester) async {
      setupGoldenTest(tester);

      when(() => mockCubit.state).thenReturn(HealthRecordInitial());
      when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
      when(() => mockCubit.close()).thenAnswer((_) async => {});

      await tester.pumpWidget(buildTestWidget(const UploadPage()));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(UploadPage),
        matchesGoldenFile("goldens/upload_page_source.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('UploadPage - Record Detail/Attachment Preview', (tester) async {
      setupGoldenTest(tester);

      when(() => mockCubit.state).thenReturn(const HealthRecordFilePicked(
        filePath: '/path/to/report.pdf',
        extractedText: 'Patient: John Doe\nDiagnosis: Hypertension\nPlan: Diet and Exercise',
      ));
      when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
      when(() => mockCubit.close()).thenAnswer((_) async => {});

      await tester.pumpWidget(buildTestWidget(const UploadPage()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      await expectLater(
        find.byType(UploadPage),
        matchesGoldenFile("goldens/upload_page_details.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('TimelinePage', (tester) async {
      setupGoldenTest(tester);

      final records = [
        MedicalRecord(
          date: DateTime(2023, 10, 1),
          type: RecordType.clinicalNote,
          summary: 'Consulta General',
        ),
      ];

      when(() => mockRepo.getAllRecords()).thenAnswer((_) async => records);
      when(() => mockWalletService.getTimeline()).thenAnswer((_) async => []);
      when(() => mockWalletService.getDataStatistics()).thenAnswer((_) async => {'labs': 0});
      when(() => mockWalletService.getAllMedicalConcepts()).thenAnswer((_) async => []);

      await tester.pumpWidget(buildTestWidget(const TimelinePage()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      await expectLater(
        find.byType(TimelinePage),
        matchesGoldenFile("goldens/timeline_page.png"),
      );
      resetGoldenTest(tester);
    });
  });
}
