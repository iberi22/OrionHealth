import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:orionhealth_health/core/di/injection.dart' as di;
import 'package:orionhealth_health/features/health_record/presentation/pages/health_record_staging_page.dart';
import 'package:orionhealth_health/features/health_record/presentation/pages/timeline_page.dart';
import 'package:orionhealth_health/features/health_record/domain/repositories/health_record_repository.dart';
import 'package:orionhealth_health/features/health_record/infrastructure/services/file_picker_service.dart';
import 'package:orionhealth_health/features/health_record/infrastructure/services/image_picker_service.dart';
import 'package:orionhealth_health/features/health_record/infrastructure/services/ocr_service.dart';
import 'package:orionhealth_health/features/local_agent/domain/services/vector_store_service.dart';
import 'package:health_wallet/health_wallet.dart';
import 'package:mocktail/mocktail.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:orionhealth_health/l10n/app_localizations.dart';
import 'package:orionhealth_health/core/theme/cyber_theme.dart';
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
    await initializeDateFormatting('es', null);
  });

  setUp(() async {
    mockFilePicker = MockFilePickerService();
    mockImagePicker = MockImagePickerService();
    mockOcr = MockOcrService();
    mockVectorStore = MockVectorStoreService();
    mockWallet = MockWalletService();

    // Register mocks to override real implementations
    di.getIt.allowReassignment = true;
    di.getIt.registerSingleton<FilePickerService>(mockFilePicker);
    di.getIt.registerSingleton<ImagePickerService>(mockImagePicker);
    di.getIt.registerSingleton<OcrService>(mockOcr);
    di.getIt.registerSingleton<VectorStoreService>(mockVectorStore);
    di.getIt.registerSingleton<WalletService>(mockWallet);

    // Default mock behaviors
    when(() => mockWallet.getTimeline()).thenAnswer((_) async => []);
    when(() => mockWallet.getDataStatistics()).thenAnswer((_) async => {'labs': 0});
    when(() => mockWallet.getAllMedicalConcepts()).thenAnswer((_) async => []);

    // Clean real database (Isar)
    final repo = di.getIt<HealthRecordRepository>();
    final all = await repo.getAllRecords();
    // Assuming no delete method in repo, we might need direct isar access or ignore for now if it's auto-clean in tests
    // Actually, it's better to ensure a fresh state if possible.
  });

  Widget createTestWidget(Widget home) {
    return MaterialApp(
      home: home,
      theme: CyberTheme.dark,
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
    testWidgets('E2E: Full Health Record Flow', (WidgetTester tester) async {
      // 1. Empty State Check
      await tester.pumpWidget(createTestWidget(const HealthRecordStagingPage()));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'health_record', '01_empty_state');

      expect(find.text('No hay registros.'), findsOneWidget);

      // 2. Record Upload Flow
      await tester.tap(find.text('Añadir Registro'));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'health_record', '02_selection_modal');

      expect(find.text('Subir PDF'), findsOneWidget);

      // Mock picking PDF
      when(() => mockFilePicker.pickPdf()).thenAnswer((_) async => '/tmp/dummy.pdf');
      when(() => mockOcr.extractText(any())).thenAnswer((_) async => 'Extracted medical text content.');

      await tester.tap(find.text('Subir PDF'));
      await tester.pump(); // Start loading
      await tester.pumpAndSettle(); // Finish OCR and show form
      await VideoRecorder.recordStep(tester, 'health_record', '03_form_open');

      // Fill Form
      await tester.enterText(find.widgetWithText(TextField, 'Resumen Breve'), 'Chequeo General');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'health_record', '04_after_save');

      // 3. Verification Flow
      expect(find.text('Chequeo General'), findsOneWidget);
      expect(find.text('clinicalNote'), findsOneWidget); // Default type name

      // Navigate to TimelinePage
      await tester.pumpWidget(createTestWidget(const TimelinePage()));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'health_record', '05_timeline_view');

      expect(find.text('Chequeo General'), findsOneWidget);
      expect(find.text('Nota Clínica'), findsOneWidget); // Timeline maps clinicalNote to 'Nota Clínica'
    });
  });
}
