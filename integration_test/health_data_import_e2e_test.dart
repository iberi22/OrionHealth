import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/core/di/injection.dart' as di;
import 'package:orionhealth_health/features/health_data_import/presentation/pages/health_import_page.dart';
import 'package:orionhealth_health/features/health_data_import/domain/usecases/health_import_usecases.dart';
import 'package:orionhealth_health/features/health_data_import/domain/entities/health_data_source.dart';
import 'package:orionhealth_health/features/vitals/domain/repositories/vital_sign_repository.dart';
import 'package:orionhealth_health/features/vitals/domain/entities/vital_sign.dart';
import 'package:orionhealth_health/features/user_profile/presentation/pages/user_profile_page.dart';
import 'package:orionhealth_health/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'utils/video_recorder.dart';

class MockGetAvailableSourcesUseCase extends Mock implements GetAvailableSourcesUseCase {}
class MockRequestHealthAuthUseCase extends Mock implements RequestHealthAuthUseCase {}
class MockImportHealthDataUseCase extends Mock implements ImportHealthDataUseCase {}
class MockVitalSignRepository extends Mock implements VitalSignRepository {}

class FakeVitalSign extends Fake implements VitalSign {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockGetAvailableSourcesUseCase mockGetAvailableSourcesUseCase;
  late MockRequestHealthAuthUseCase mockRequestHealthAuthUseCase;
  late MockImportHealthDataUseCase mockImportHealthDataUseCase;
  late MockVitalSignRepository mockVitalSignRepository;

  setUpAll(() async {
    await di.configureDependencies();
    registerFallbackValue(FakeVitalSign());
    registerFallbackValue(<VitalSign>[]);
    registerFallbackValue(HealthDataSource.googleFit);
  });

  setUp(() {
    di.getIt.allowReassignment = true;
    mockGetAvailableSourcesUseCase = MockGetAvailableSourcesUseCase();
    mockRequestHealthAuthUseCase = MockRequestHealthAuthUseCase();
    mockImportHealthDataUseCase = MockImportHealthDataUseCase();
    mockVitalSignRepository = MockVitalSignRepository();

    di.getIt.registerSingleton<GetAvailableSourcesUseCase>(mockGetAvailableSourcesUseCase);
    di.getIt.registerSingleton<RequestHealthAuthUseCase>(mockRequestHealthAuthUseCase);
    di.getIt.registerSingleton<ImportHealthDataUseCase>(mockImportHealthDataUseCase);
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

  tearDown(() {
     di.getIt.unregister<HealthDataImportService>();
     di.getIt.unregister<VitalSignRepository>();
  });

  Widget createImportTestWidget(Widget home) {
    return MaterialApp(
      home: home,
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

  group('Health Data Import Flow - True E2E Tests', () {
    testWidgets('E2E: Navigation to Import Page and Full Flow from Google Fit', (WidgetTester tester) async {
      // 1. Mock initial data
      when(() => mockGetAvailableSourcesUseCase())
          .thenAnswer((_) async => [HealthDataSource.googleFit]);

      // Start from User Profile to test navigation
      await tester.pumpWidget(createImportTestWidget(const UserProfilePage()));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'health_data_import', '01_user_profile');

      final l10n = await AppLocalizations.delegate.load(const Locale('es'));

      // Navigate to Importar Datos
      final importTile = find.text(l10n.importData);
      await tester.scrollUntilVisible(importTile, 100);
      await tester.tap(importTile);
      await tester.pumpAndSettle();

      // Verify Health Import Page is shown
      expect(find.byType(HealthImportPage), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'health_data_import', '02_import_ready');

      // Verify Google Fit is available
      expect(find.text('Google Fit / Health Connect'), findsOneWidget);

      // 3. Setup mocks for the import process
      when(() => mockRequestHealthAuthUseCase(any()))
          .thenAnswer((_) async => true);

      when(() => mockImportHealthDataUseCase(any()))
          .thenAnswer((_) => Stream.fromIterable([
            const ImportProgress(
              currentStep: 'Importing steps...',
              totalSteps: 8,
              currentStepNum: 1,
              importedCount: 0,
            ),
            const ImportProgress(
              currentStep: 'Completed',
              totalSteps: 8,
              currentStepNum: 8,
              importedCount: 10,
              isCompleted: true,
            ),
          ]));

      // Trigger Import
      await tester.tap(find.text('Import Data'));
      await tester.pump(); // Start the flow

      // Verify Authentication state
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.textContaining('Requesting permission from'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'health_data_import', '03_authenticating');

      await tester.pumpAndSettle();

      // Verify Success SnackBar
      expect(find.textContaining('Successfully imported'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'health_data_import', '04_success');
    });

    testWidgets('Handling Authorization Denied', (WidgetTester tester) async {
      when(() => mockGetAvailableSourcesUseCase())
          .thenAnswer((_) async => [HealthDataSource.googleFit]);
      when(() => mockRequestHealthAuthUseCase(any()))
          .thenAnswer((_) async => false);

      await tester.pumpWidget(createImportTestWidget(const HealthImportPage()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Import Data'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Authorization denied'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'health_data_import', '04_auth_denied');
    });

    group('E2E: Import Health Data from Multiple Sources', () {
      testWidgets('Shows multiple available sources', (WidgetTester tester) async {
        when(() => mockGetAvailableSourcesUseCase())
            .thenAnswer((_) async => [HealthDataSource.googleFit, HealthDataSource.samsungHealth]);

        await tester.pumpWidget(const MaterialApp(home: HealthImportPage()));
        await tester.pumpAndSettle();

        expect(find.text('Google Fit / Health Connect'), findsOneWidget);
        expect(find.text('Samsung Health'), findsOneWidget);

        await VideoRecorder.recordStep(tester, 'health_data_import', '05_multiple_sources');
      });
    });
   group('E2E: Progress tracking', () {
      testWidgets('Shows progress during import', (WidgetTester tester) async {
         when(() => mockGetAvailableSourcesUseCase())
            .thenAnswer((_) async => [HealthDataSource.googleFit]);
         when(() => mockRequestHealthAuthUseCase(any()))
            .thenAnswer((_) async => true);

         final progressController = StreamController<ImportProgress>();
         when(() => mockImportHealthDataUseCase(any()))
            .thenAnswer((_) => progressController.stream);

         await tester.pumpWidget(const MaterialApp(home: HealthImportPage()));
         await tester.pumpAndSettle();

         await tester.tap(find.text('Import Data'));
         await tester.pumpAndSettle();

         progressController.add(const ImportProgress(
            currentStep: 'Fetching data...',
            totalSteps: 10,
            currentStepNum: 5,
            importedCount: 50,
         ));

         await tester.pump();
         expect(find.text('Fetching data...'), findsOneWidget);
         expect(find.text('Step 5 of 10'), findsOneWidget);
         expect(find.text('50 imported'), findsOneWidget);

         progressController.add(const ImportProgress(
            currentStep: 'Done',
            totalSteps: 10,
            currentStepNum: 10,
            importedCount: 100,
            isCompleted: true,
         ));
         await tester.pumpAndSettle();

         expect(find.textContaining('Successfully imported 100 records'), findsOneWidget);
         await progressController.close();
      });
    });
  });
}
