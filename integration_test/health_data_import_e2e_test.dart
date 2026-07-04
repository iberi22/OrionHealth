import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:orionhealth_health/core/di/injection.dart';
import 'package:orionhealth_health/features/health_data_import/presentation/pages/health_import_page.dart';
import 'package:orionhealth_health/features/health_data_import/application/health_import_cubit.dart';
import 'package:orionhealth_health/features/health_data_import/domain/entities/health_data_source.dart';
import 'package:orionhealth_health/features/health_data_import/domain/services/health_data_import_service.dart';
import 'package:orionhealth_health/features/vitals/domain/repositories/vital_sign_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter/services.dart';
import 'utils/video_recorder.dart';

class MockHealthDataImportService extends Mock implements HealthDataImportService {}
class MockVitalSignRepository extends Mock implements VitalSignRepository {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockHealthDataImportService mockService;
  late MockVitalSignRepository mockVitalRepo;
  late HealthImportCubit cubit;

  setUpAll(() {
    registerFallbackValue(HealthDataSource.googleFit);
    registerFallbackValue([]);
  });

  setUp(() {
    mockService = MockHealthDataImportService();
    mockVitalRepo = MockVitalSignRepository();

    cubit = HealthImportCubit(mockService, mockVitalRepo);

    // Register in GetIt
    getIt.allowReassignment = true;
    getIt.registerSingleton<HealthImportCubit>(cubit);

    // Mock local_auth channel
    const MethodChannel channel = MethodChannel('plugins.flutter.io/local_auth');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'canCheckBiometrics':
          return true;
        case 'isDeviceSupported':
          return true;
        case 'getAvailableBiometrics':
          return <String>['fingerprint'];
        case 'authenticate':
          return true;
        default:
          return null;
      }
    });

    // Default mocks for service
    when(() => mockService.getAvailableSources()).thenAnswer((_) async => [HealthDataSource.googleFit]);
    when(() => mockService.requestAuthorization(any())).thenAnswer((_) async => true);
    when(() => mockService.fetchSteps()).thenAnswer((_) async => []);
    when(() => mockService.fetchDistance()).thenAnswer((_) async => []);
    when(() => mockService.fetchHeartRate()).thenAnswer((_) async => []);
    when(() => mockService.fetchSleep()).thenAnswer((_) async => []);
    when(() => mockService.fetchBloodGlucose()).thenAnswer((_) async => []);
    when(() => mockService.fetchBloodPressure()).thenAnswer((_) async => []);
    when(() => mockService.fetchHeight()).thenAnswer((_) async => []);
    when(() => mockService.fetchWeight()).thenAnswer((_) async => []);
    when(() => mockService.fetchOxygenSaturation()).thenAnswer((_) async => []);
    when(() => mockService.convertToVitalSigns(any(), any())).thenAnswer((_) async => []);

    when(() => mockVitalRepo.saveVitalSigns(any())).thenAnswer((_) async => {});
  });

  tearDown(() {
    getIt.unregister<HealthImportCubit>();
  });

  group('Health Data Import Flow - E2E Tests', () {
    testWidgets('E2E: Full Import Flow from Google Fit', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: HealthImportPage(),
      ));

      // Wait for initial loading (checkAvailableSources)
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'health_import', '01_ready');

      expect(find.text('Google Fit / Health Connect'), findsOneWidget);
      expect(find.text('Available'), findsOneWidget);

      // Tap Import Data
      await tester.tap(find.text('Import Data'));

      // The page will:
      // 1. Authenticate Biometric (Mocked to return true)
      // 2. cubit.importFromSource(googleFit)

      await tester.pump(); // Start authentication
      await tester.pump(const Duration(milliseconds: 100)); // Process auth

      // Should show Requesting permission dialog (Authenticating state)
      // Note: we use find.textContaining because it's in a dialog
      expect(find.textContaining('Requesting permission from Google Fit'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'health_import', '02_authenticating');

      await tester.pump(); // Move to Importing

      // Should show ImportProgressDialog
      expect(find.text('Importing data...'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'health_import', '03_importing');

      // Finalize import
      await tester.pumpAndSettle();

      // Success SnackBar should appear
      expect(find.textContaining('Successfully imported 0 records'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'health_import', '04_success');
    });

    testWidgets('E2E: Import Error handling', (WidgetTester tester) async {
      when(() => mockService.requestAuthorization(any())).thenThrow(Exception('Auth Failed'));

      await tester.pumpWidget(const MaterialApp(
        home: HealthImportPage(),
      ));

      await tester.pumpAndSettle();

      await tester.tap(find.text('Import Data'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      // Error SnackBar should appear
      expect(find.textContaining('Error: Import failed: Exception: Auth Failed'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'health_import', '05_error');
    });
  });
}
