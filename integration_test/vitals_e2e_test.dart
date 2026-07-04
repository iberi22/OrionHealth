import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:orionhealth_health/core/di/injection.dart';
import 'package:orionhealth_health/core/theme/cyber_theme.dart';
import 'package:orionhealth_health/features/vitals/presentation/pages/vitals_page.dart';
import 'package:orionhealth_health/features/vitals/presentation/pages/vitals_monitor_page.dart';
import 'package:orionhealth_health/features/vitals/domain/entities/vital_sign.dart';
import 'package:orionhealth_health/features/vitals/domain/repositories/vital_sign_repository.dart';
import 'package:orionhealth_health/features/health_sharing/infrastructure/ble_sharing_service.dart';
import 'package:mocktail/mocktail.dart';
import 'utils/video_recorder.dart';

class MockVitalSignRepository extends Mock implements VitalSignRepository {}
class MockBleSharingService extends Mock implements BleSharingService {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockVitalSignRepository mockRepository;
  late MockBleSharingService mockBleService;

  setUpAll(() {
    registerFallbackValue(VitalSign(
      type: VitalSignType.heartRate,
      value: 0,
      dateTime: DateTime.now(),
    ));
  });

  setUp(() {
    mockRepository = MockVitalSignRepository();
    mockBleService = MockBleSharingService();

    // Ensure GetIt is clean
    if (getIt.isRegistered<VitalSignRepository>()) {
      getIt.unregister<VitalSignRepository>();
    }
    if (getIt.isRegistered<BleSharingService>()) {
      getIt.unregister<BleSharingService>();
    }

    getIt.registerSingleton<VitalSignRepository>(mockRepository);
    getIt.registerSingleton<BleSharingService>(mockBleService);

    when(() => mockBleService.initialize()).thenAnswer((_) async {});
  });

  Widget createTestableWidget(Widget child) {
    return MaterialApp(
      theme: CyberTheme.dark,
      home: child,
    );
  }

  group('Vitals Flow - E2E Tests', () {
    testWidgets('E2E: Vitals Dashboard and Manual Entry', (WidgetTester tester) async {
      final now = DateTime.now();
      final vitals = [
        VitalSign(type: VitalSignType.heartRate, value: 72, dateTime: now),
        VitalSign(type: VitalSignType.bloodPressureSystolic, value: 120, dateTime: now),
        VitalSign(type: VitalSignType.bloodPressureDiastolic, value: 80, dateTime: now),
        VitalSign(type: VitalSignType.temperature, value: 36.6, dateTime: now),
        VitalSign(type: VitalSignType.spO2, value: 98, dateTime: now),
      ];

      when(() => mockRepository.getLatestVitals()).thenAnswer((_) async => {
        VitalSignType.heartRate: vitals[0],
        VitalSignType.bloodPressureSystolic: vitals[1],
        VitalSignType.bloodPressureDiastolic: vitals[2],
        VitalSignType.temperature: vitals[3],
        VitalSignType.spO2: vitals[4],
      });
      when(() => mockRepository.getAllVitalSigns()).thenAnswer((_) async => vitals);

      await tester.pumpWidget(createTestableWidget(const VitalsPage()));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'vitals', '01_dashboard');

      // Verify Latest Vitals Cards
      expect(find.text('72.0'), findsOneWidget);
      expect(find.text('120/80'), findsOneWidget);
      expect(find.text('36.6'), findsOneWidget);
      expect(find.text('98.0'), findsOneWidget);

      // Scroll to see historical list
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'vitals', '02_historical_list');

      // Verify Historical List Items - using contains to be less locale-dependent if needed,
      // but here they are explicitly what VitalsPage uses in Spanish.
      expect(find.textContaining('72.0'), findsWidgets);
      expect(find.textContaining('36.6'), findsWidgets);

      // Add manual entry
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'vitals', '03_add_bottom_sheet');

      await tester.enterText(find.widgetWithText(TextField, 'Valor'), '75.5');

      // Select another type
      await tester.tap(find.byType(DropdownButtonFormField<VitalSignType>));
      await tester.pumpAndSettle();
      // Use find.textContaining for flexibility
      await tester.tap(find.textContaining('Temperatura').last);
      await tester.pumpAndSettle();

      when(() => mockRepository.saveVitalSign(any())).thenAnswer((_) async {
        final newVital = VitalSign(type: VitalSignType.temperature, value: 75.5, dateTime: DateTime.now());
        vitals.add(newVital);
        // Re-mocking latest vitals
        when(() => mockRepository.getLatestVitals()).thenAnswer((_) async => {
          VitalSignType.heartRate: vitals[0],
          VitalSignType.bloodPressureSystolic: vitals[1],
          VitalSignType.bloodPressureDiastolic: vitals[2],
          VitalSignType.temperature: newVital,
          VitalSignType.spO2: vitals[4],
        });
        when(() => mockRepository.getAllVitalSigns()).thenAnswer((_) async => vitals);
      });

      await tester.tap(find.textContaining('Guardar'));
      await tester.pumpAndSettle();

      verify(() => mockRepository.saveVitalSign(any())).called(1);
      await tester.pumpAndSettle();

      // Verify updated value in card
      expect(find.text('75.5'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'vitals', '04_after_add_manual');
    });

    testWidgets('E2E: Vitals Monitor - BLE Device Scan and Connect', (WidgetTester tester) async {
      final devices = [
        const BleDevice(id: '1', name: 'Orion Band Pro', type: 'Heart Rate Monitor'),
        const BleDevice(id: '2', name: 'Smart Thermometer', type: 'Health Thermometer'),
      ];

      when(() => mockBleService.scanForDevices()).thenAnswer((_) async => devices);
      when(() => mockBleService.connect(any())).thenAnswer((_) async => true);
      when(() => mockBleService.startMedicalDataStream(any())).thenAnswer((_) async {});

      await tester.pumpWidget(createTestableWidget(const VitalsMonitorPage()));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'vitals_monitor', '01_initial');

      // Use textContaining for better resilience
      expect(find.textContaining('clinical device'), findsOneWidget);

      // Start Scan
      await tester.tap(find.textContaining('Search Devices'));
      await tester.pump(); // Start scan UI change
      expect(find.textContaining('Scanning'), findsOneWidget);
      await tester.pumpAndSettle(); // Finish scan

      expect(find.text('Orion Band Pro'), findsOneWidget);
      expect(find.text('Smart Thermometer'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'vitals_monitor', '02_scanned_devices');

      // Connect to Orion Band Pro
      await tester.tap(find.text('CONNECT').first);
      await tester.pump();
      expect(find.textContaining('Connecting to Orion Band Pro'), findsOneWidget);
      await tester.pumpAndSettle();

      expect(find.textContaining('Connected to Orion Band Pro'), findsOneWidget);
      verify(() => mockBleService.connect('1')).called(1);
      verify(() => mockBleService.startMedicalDataStream('1')).called(1);

      // Wait for simulated data fluctuation (Timer in VitalsMonitorPage)
      await tester.pump(const Duration(seconds: 1));
      await VideoRecorder.recordStep(tester, 'vitals_monitor', '03_live_data');

      // Verify that some BPM value is shown (not --)
      final bpmTextFinder = find.byWidgetPredicate(
        (w) => w is Text && w.style?.fontSize == 80,
      );
      final bpmText = tester.widget<Text>(bpmTextFinder);
      expect(bpmText.data, isNot('--'));

      // Check the unit
      expect(find.text('BPM'), findsOneWidget);
    });
  });
}
