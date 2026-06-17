import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:orionhealth_health/features/health_record/presentation/pages/health_record_staging_page.dart';
import 'package:orionhealth_health/features/health_record/presentation/pages/upload_page.dart';
import 'package:orionhealth_health/features/health_record/presentation/pages/timeline_page.dart';
import 'package:orionhealth_health/features/health_record/application/bloc/health_record_cubit.dart';
import 'package:orionhealth_health/features/health_record/domain/entities/medical_record.dart';
import 'package:orionhealth_health/features/health_record/domain/repositories/health_record_repository.dart';
import 'package:health_wallet/health_wallet.dart';

class MockHealthRecordCubit extends Mock implements HealthRecordCubit {}
class MockHealthRecordRepository extends Mock implements HealthRecordRepository {}
class MockWalletService extends Mock implements WalletService {}

void main() {
  late MockHealthRecordCubit mockCubit;
  late MockHealthRecordRepository mockRepo;
  late MockWalletService mockWalletService;

  setUpAll(() {
    final getIt = GetIt.instance;
    mockCubit = MockHealthRecordCubit();
    mockRepo = MockHealthRecordRepository();
    mockWalletService = MockWalletService();

    getIt.registerLazySingleton<HealthRecordCubit>(() => mockCubit);
    getIt.registerLazySingleton<HealthRecordRepository>(() => mockRepo);
    getIt.registerLazySingleton<WalletService>(() => mockWalletService);
  });

  tearDownAll(() {
    GetIt.I.reset();
  });

  group('Health Record Golden Tests', () {
    testWidgets('HealthRecordStagingPage - History View', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;

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

      await tester.pumpWidget(const MaterialApp(home: HealthRecordStagingPage()));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(HealthRecordStagingPage),
        matchesGoldenFile("../../../../golden/reference/health_record_staging_history.png"),
      );
    });

    testWidgets('UploadPage - Source Selection', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;

      when(() => mockCubit.state).thenReturn(HealthRecordInitial());
      when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(const MaterialApp(home: UploadPage()));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(UploadPage),
        matchesGoldenFile("../../../../golden/reference/upload_page_source.png"),
      );
    });

    testWidgets('UploadPage - Record Detail/Attachment Preview', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;

      when(() => mockCubit.state).thenReturn(const HealthRecordFilePicked(
        filePath: '/path/to/report.pdf',
        extractedText: 'Patient: John Doe\nDiagnosis: Hypertension\nPlan: Diet and Exercise',
      ));
      when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(const MaterialApp(home: UploadPage()));
      // UploadPage has some animations or something that makes pumpAndSettle hang?
      // Or maybe it's the same issue.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      await expectLater(
        find.byType(UploadPage),
        matchesGoldenFile("../../../../golden/reference/upload_page_details.png"),
      );
    });

    testWidgets('TimelinePage', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;

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

      await tester.pumpWidget(const MaterialApp(home: TimelinePage()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      await expectLater(
        find.byType(TimelinePage),
        matchesGoldenFile("../../../../golden/reference/timeline_page.png"),
      );
    });
   group('Health Record Golden Tests Extra', () {
    testWidgets('HealthRecordStagingPage - File Picked (Form)', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;

      when(() => mockCubit.state).thenReturn(const HealthRecordFilePicked(
        filePath: 'test.pdf',
        extractedText: 'Extracted text here',
      ));
      when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(const MaterialApp(home: HealthRecordStagingPage()));
      await tester.pump();

      await expectLater(
        find.byType(HealthRecordStagingPage),
        matchesGoldenFile("../../../../golden/reference/health_record_staging_form.png"),
      );
    });
   });
  });
}
