import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:isar/isar.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/core/di/injection.dart' as di;
import 'package:orionhealth_health/features/health_record/presentation/pages/health_record_staging_page.dart';
import 'package:orionhealth_health/features/health_record/presentation/pages/timeline_page.dart';
import 'package:orionhealth_health/features/health_record/infrastructure/services/file_picker_service.dart';
import 'package:orionhealth_health/features/health_record/infrastructure/services/image_picker_service.dart';
import 'package:orionhealth_health/features/health_record/infrastructure/services/ocr_service.dart';
import 'package:orionhealth_health/features/local_agent/domain/services/vector_store_service.dart';
import 'package:health_wallet/health_wallet.dart';
import 'package:orionhealth_health/features/health_record/domain/entities/medical_record.dart';
import 'package:orionhealth_health/l10n/app_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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
  late Isar isar;

  setUpAll(() async {
    await di.configureDependencies();
    di.getIt.allowReassignment = true;
    await initializeDateFormatting('es', null);
    isar = di.getIt<Isar>();
  });

  setUp(() async {
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

    // Clear Isar database before each test
    await isar.writeTxn(() => isar.medicalRecords.clear());

    // Default mock behavior for WalletService to avoid null errors in TimelinePage
    when(() => mockWallet.getTimeline()).thenAnswer((_) async => []);
    when(() => mockWallet.getDataStatistics()).thenAnswer((_) async => {'labs': 0});
    when(() => mockWallet.getAllMedicalConcepts()).thenAnswer((_) async => []);
  });

  Widget createWidgetUnderTest(Widget page) {
    return MaterialApp(
      home: page,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('es'),
    );
  }

  group('Health Record Flow - E2E Tests', () {
    testWidgets('E2E: Empty state and Upload Record Flow', (WidgetTester tester) async {
      // 1. Verify Empty State
      await tester.pumpWidget(createWidgetUnderTest(const HealthRecordStagingPage()));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'health_record', '01_empty_state');

      expect(find.text('No hay registros.'), findsOneWidget);

      // 2. Open Upload Modal
      await tester.tap(find.text('Añadir Registro'));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'health_record', '02_selection_modal');

      // 3. Select Subir PDF
      when(() => mockFilePicker.pickPdf()).thenAnswer((_) async => '/tmp/test.pdf');
      when(() => mockOcr.extractText(any())).thenAnswer((_) async => 'OCR extraction result');

      await tester.tap(find.text('Subir PDF'));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'health_record', '03_record_form');

      // 4. Fill Form
      final summaryField = find.widgetWithText(TextFormField, 'Resumen Breve');
      await tester.enterText(summaryField, 'Test Lab Summary');

      // Select Record Type
      await tester.tap(find.text('Tipo de Documento'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('labResult').last);
      await tester.pumpAndSettle();

      await VideoRecorder.recordStep(tester, 'health_record', '04_form_filled');

      // 5. Save Record
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();

      expect(find.text('Registro guardado exitosamente'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'health_record', '05_saved_snackbar');

      // Wait for snackbar to disappear or just pump enough
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();

      // 6. Verify in Staging Page List
      expect(find.text('Test Lab Summary'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'health_record', '06_staging_list_updated');

      // 7. Verify in Timeline Page
      await tester.pumpWidget(createWidgetUnderTest(const TimelinePage()));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'health_record', '07_timeline_view');

      expect(find.text('Resultado de Laboratorio'), findsOneWidget);
      expect(find.text('Test Lab Summary'), findsOneWidget);
    });
  });
}
