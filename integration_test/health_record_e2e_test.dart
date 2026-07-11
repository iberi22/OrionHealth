// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:orionhealth_health/core/di/injection.dart' as di;
import 'package:orionhealth_health/features/health_record/presentation/pages/timeline_page.dart';
import 'package:orionhealth_health/features/health_record/presentation/pages/health_record_staging_page.dart';
import 'package:orionhealth_health/features/health_record/domain/entities/medical_record.dart';
import 'package:orionhealth_health/features/health_record/infrastructure/services/file_picker_service.dart';
import 'package:orionhealth_health/features/health_record/infrastructure/services/image_picker_service.dart';
import 'package:orionhealth_health/features/health_record/infrastructure/services/ocr_service.dart';
import 'package:orionhealth_health/features/local_agent/domain/services/vector_store_service.dart';
import 'package:health_wallet/health_wallet.dart';
import 'package:mocktail/mocktail.dart';
import 'package:isar/isar.dart';
import 'utils/video_recorder.dart';

class MockFilePickerService extends Mock implements FilePickerService {}
class MockImagePickerService extends Mock implements ImagePickerService {}
class MockOcrService extends Mock implements OcrService {}
class MockVectorStoreService extends Mock implements VectorStoreService {}
class MockWalletService extends Mock implements WalletService {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockFilePickerService mockFilePicker;
  late MockImagePickerService mockImagePicker;
  late MockOcrService mockOcr;
  late MockVectorStoreService mockVectorStore;
  late MockWalletService mockWallet;

  setUpAll(() async {
    await di.configureDependencies();
    di.getIt.allowReassignment = true;

    mockFilePicker = MockFilePickerService();
    mockImagePicker = MockImagePickerService();
    mockOcr = MockOcrService();
    mockVectorStore = MockVectorStoreService();
    mockWallet = MockWalletService();

    di.getIt.registerSingleton<FilePickerService>(mockFilePicker);
    di.getIt.registerSingleton<ImagePickerService>(mockImagePicker);
    di.getIt.registerSingleton<OcrService>(mockOcr);
    di.getIt.registerSingleton<VectorStoreService>(mockVectorStore);
    di.getIt.registerSingleton<WalletService>(mockWallet);
  });

  group('Health Record Flow - E2E Tests', () {
    testWidgets('E2E: Initial Empty States', (WidgetTester tester) async {
      // Clear database
      final isar = di.getIt<Isar>();
      await isar.writeTxn(() => isar.medicalRecords.clear());

      when(() => mockWallet.getTimeline()).thenAnswer((_) async => []);
      when(() => mockWallet.getDataStatistics()).thenAnswer((_) async => {'labs': 0});
      when(() => mockWallet.getAllMedicalConcepts()).thenAnswer((_) async => []);

      // 1. Check Staging Page
      await tester.pumpWidget(const MaterialApp(home: HealthRecordStagingPage()));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'health_record', '01_staging_empty');
      expect(find.text('No hay registros.'), findsOneWidget);

      // 2. Check Timeline Page
      await tester.pumpWidget(const MaterialApp(home: TimelinePage()));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'health_record', '02_timeline_empty');
      expect(find.text('No hay eventos en tu historial médico.'), findsOneWidget);
    });

    testWidgets('E2E: Record Upload Flow and Verification', (WidgetTester tester) async {
      final isar = di.getIt<Isar>();
      await isar.writeTxn(() => isar.medicalRecords.clear());

      when(() => mockWallet.getTimeline()).thenAnswer((_) async => []);
      when(() => mockWallet.getDataStatistics()).thenAnswer((_) async => {'labs': 0});
      when(() => mockWallet.getAllMedicalConcepts()).thenAnswer((_) async => []);

      // Setup Mocks for Upload
      const dummyPath = '/path/to/test.pdf';
      const extractedText = 'Sample medical report text';
      const summary = 'Examen de sangre anual';

      when(() => mockFilePicker.pickPdf()).thenAnswer((_) async => dummyPath);
      when(() => mockOcr.extractText(dummyPath)).thenAnswer((_) async => extractedText);

      await tester.pumpWidget(const MaterialApp(home: HealthRecordStagingPage()));
      await tester.pumpAndSettle();

      // 1. Start Upload Flow
      await tester.tap(find.text('Añadir Registro'));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'health_record', '03_upload_modal');

      await tester.tap(find.text('Subir PDF'));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'health_record', '04_record_form');

      // 2. Fill Form
      // Find Dropdown for Tipo de Documento
      await tester.tap(find.text('clinicalNote')); // Default value in code
      await tester.pumpAndSettle();
      await tester.tap(find.text('labResult').last);
      await tester.pumpAndSettle();

      // Fill Summary
      await tester.enterText(find.widgetWithText(TextFormField, 'Resumen Breve'), summary);
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'health_record', '05_form_filled');

      // 3. Save
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'health_record', '06_after_save');

      expect(find.text('Registro guardado exitosamente'), findsOneWidget);

      // 4. Verify in Timeline
      await tester.pumpWidget(const MaterialApp(home: TimelinePage()));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'health_record', '07_timeline_with_data');

      expect(find.text('Resultado de Laboratorio'), findsOneWidget);
      expect(find.text(summary), findsOneWidget);
    });
  });
}
