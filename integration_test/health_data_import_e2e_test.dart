import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:orionhealth_health/core/di/injection.dart' as di;
import 'package:orionhealth_health/features/health_data_import/presentation/pages/health_import_page.dart';
import 'package:orionhealth_health/features/health_data_import/domain/services/health_data_import_service.dart';
import 'package:orionhealth_health/features/vitals/domain/repositories/vital_sign_repository.dart';
import 'package:orionhealth_health/features/health_data_import/domain/entities/health_data_source.dart';
import 'package:orionhealth_health/features/vitals/domain/entities/vital_sign.dart';
import 'package:mocktail/mocktail.dart';
import 'utils/video_recorder.dart';

class MockHealthDataImportService extends Mock implements HealthDataImportService {}
class MockVitalSignRepository extends Mock implements VitalSignRepository {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockHealthDataImportService mockImportService;
  late MockVitalSignRepository mockVitalSignRepository;

  setUpAll(() async {
    await di.configureDependencies();
    di.getIt.allowReassignment = true;

    registerFallbackValue(HealthDataSource.googleFit);
    registerFallbackValue(<VitalSign>[]);
    registerFallbackValue(<dynamic>[]);
  });

  setUp(() {
    mockImportService = MockHealthDataImportService();
    mockVitalSignRepository = MockVitalSignRepository();

    di.getIt.registerSingleton<HealthDataImportService>(mockImportService);
    di.getIt.registerSingleton<VitalSignRepository>(mockVitalSignRepository);

    // Mock local_auth platform channel
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/local_auth'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'authenticate') {
          return true;
        }
        if (methodCall.method == 'canCheckBiometrics' ||
            methodCall.method == 'isDeviceSupported' ||
            methodCall.method == 'getEnrolledBiometrics') {
          if (methodCall.method == 'getEnrolledBiometrics') return <String>['fingerprint'];
          return true;
        }
        return null;
      },
    );
  });

  tearDown(() {
    di.getIt.unregister<HealthDataImportService>();
    di.getIt.unregister<VitalSignRepository>();
  });

  group('Health Data Import Flow - E2E Tests', () {
    testWidgets('E2E: Full Import Flow from Google Fit', (WidgetTester tester) async {
      // 1. MOCK SERVICE RESPONSES
      when(() => mockImportService.getAvailableSources())
          .thenAnswer((_) async => [HealthDataSource.googleFit]);

      when(() => mockImportService.requestAuthorization(any()))
          .thenAnswer((_) async => true);

      // Mock data fetching (return empty lists for simplicity)
      when(() => mockImportService.fetchSteps()).thenAnswer((_) async => []);
      when(() => mockImportService.fetchDistance()).thenAnswer((_) async => []);
      when(() => mockImportService.fetchHeartRate()).thenAnswer((_) async => []);
      when(() => mockImportService.fetchSleep()).thenAnswer((_) async => []);
      when(() => mockImportService.fetchBloodGlucose()).thenAnswer((_) async => []);
      when(() => mockImportService.fetchBloodPressure()).thenAnswer((_) async => []);
      when(() => mockImportService.fetchHeight()).thenAnswer((_) async => []);
      when(() => mockImportService.fetchWeight()).thenAnswer((_) async => []);
      when(() => mockImportService.fetchOxygenSaturation()).thenAnswer((_) async => []);

      when(() => mockImportService.convertToVitalSigns(any(), any()))
          .thenAnswer((_) async => []);

      when(() => mockVitalSignRepository.saveVitalSigns(any()))
          .thenAnswer((_) async => {});

      // 2. START THE PAGE
      await tester.pumpWidget(
        MaterialApp(
          home: const HealthImportPage(),
          theme: ThemeData.dark(),
        ),
      );

      // Wait for availability check
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'health_import', '01_ready_view');

      // Verify Google Fit is available
      expect(find.text('Google Fit / Health Connect'), findsOneWidget);
      expect(find.text('Available'), findsOneWidget);

      // 3. TRIGGER IMPORT
      final importButton = find.widgetWithText(ElevatedButton, 'Import Data');
      await tester.tap(importButton);

      // First pump for the tap and the biometric dialog logic
      await tester.pump();

      // Wait for the async biometric check to finish and the cubit to start
      await tester.pump(const Duration(milliseconds: 100));
      // Now the progress dialog should be visible
      await VideoRecorder.recordStep(tester, 'health_import', '02_importing_dialog');

      // 4. WAIT FOR COMPLETION
      // The import process has multiple steps. pumpAndSettle should wait for the animations and state changes.
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'health_import', '03_success_snackbar');

      // 5. VERIFY SUCCESS
      expect(find.textContaining('Successfully imported'), findsOneWidget);

      // Verify repository was called (8 times for 8 categories of data)
      verify(() => mockVitalSignRepository.saveVitalSigns(any())).called(greaterThan(0));
    });
  });
}
