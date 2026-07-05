import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:orionhealth_health/core/di/injection.dart' as di;
import 'package:orionhealth_health/features/health_data_import/presentation/pages/health_import_page.dart';
import 'package:orionhealth_health/features/health_data_import/domain/services/health_data_import_service.dart';
import 'package:orionhealth_health/features/health_data_import/domain/entities/health_data_source.dart';
import 'package:orionhealth_health/features/vitals/domain/repositories/vital_sign_repository.dart';
import 'package:orionhealth_health/features/vitals/domain/entities/vital_sign.dart';
import 'package:mocktail/mocktail.dart';
import 'utils/video_recorder.dart';

class MockHealthDataImportService extends Mock implements HealthDataImportService {}
class MockVitalSignRepository extends Mock implements VitalSignRepository {}

class FakeVitalSign extends Fake implements VitalSign {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockHealthDataImportService mockImportService;
  late MockVitalSignRepository mockVitalSignRepository;

  setUpAll(() async {
    await di.configureDependencies();
    registerFallbackValue(FakeVitalSign());
    registerFallbackValue(<VitalSign>[]);
    registerFallbackValue(HealthDataSource.googleFit);
  });

  setUp(() {
    di.getIt.allowReassignment = true;
    mockImportService = MockHealthDataImportService();
    mockVitalSignRepository = MockVitalSignRepository();

    di.getIt.registerSingleton<HealthDataImportService>(mockImportService);
    di.getIt.registerSingleton<VitalSignRepository>(mockVitalSignRepository);

    // Mock local_auth platform channel to bypass biometrics
    const MethodChannel('plugins.flutter.io/local_auth')
        .setMockMethodCallHandler((MethodCall methodCall) async {
      if (methodCall.method == 'authenticate') {
        return true;
      }
      if (methodCall.method == 'canCheckBiometrics' || methodCall.method == 'isDeviceSupported') {
        return true;
      }
      if (methodCall.method == 'getAvailableBiometrics') {
        return <String>['fingerprint'];
      }
      return null;
    });
  });

  group('Health Data Import - E2E Tests', () {
    testWidgets('Full Import Flow from Google Fit', (WidgetTester tester) async {
      // 1. Mock initial data
      when(() => mockImportService.getAvailableSources())
          .thenAnswer((_) async => [HealthDataSource.googleFit]);

      // 2. Launch the page
      await tester.pumpWidget(const MaterialApp(
        home: HealthImportPage(),
      ));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'health_data_import', '01_ready_state');

      expect(find.text('Google Fit / Health Connect'), findsOneWidget);

      // 3. Setup mocks for the import process
      when(() => mockImportService.requestAuthorization(any()))
          .thenAnswer((_) async => true);

      // Mocking all fetch methods to return empty lists for simplicity in E2E
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

      // 4. Trigger Import
      await tester.tap(find.text('Import Data'));
      await tester.pump(); // Start the flow

      // 5. Verify Authentication state (dialog showing "Requesting permission from...")
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.textContaining('Requesting permission from'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'health_data_import', '02_authenticating');

      await tester.pumpAndSettle();

      // 6. Verify Success SnackBar
      expect(find.textContaining('Successfully imported'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'health_data_import', '03_success');
    });

    testWidgets('Handling Authorization Denied', (WidgetTester tester) async {
      when(() => mockImportService.getAvailableSources())
          .thenAnswer((_) async => [HealthDataSource.googleFit]);
      when(() => mockImportService.requestAuthorization(any()))
          .thenAnswer((_) async => false);

      await tester.pumpWidget(const MaterialApp(home: HealthImportPage()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Import Data'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Authorization denied'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'health_data_import', '04_auth_denied');
    });
   group('E2E: Import Health Data from Multiple Sources', () {
      testWidgets('Shows multiple available sources', (WidgetTester tester) async {
        when(() => mockImportService.getAvailableSources())
            .thenAnswer((_) async => [HealthDataSource.googleFit, HealthDataSource.samsungHealth]);

        await tester.pumpWidget(const MaterialApp(home: HealthImportPage()));
        await tester.pumpAndSettle();

        expect(find.text('Google Fit / Health Connect'), findsOneWidget);
        expect(find.text('Samsung Health'), findsOneWidget);

        // Verify one is marked available and another is not (simulated)
        // Actually, our mock says both are in the available list.

        await VideoRecorder.recordStep(tester, 'health_data_import', '05_multiple_sources');
      });
    });
  });
}
