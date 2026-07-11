import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:orionhealth_health/core/di/injection.dart' as di;
import 'package:orionhealth_health/features/vitals/presentation/pages/vitals_page.dart';
import 'package:orionhealth_health/features/vitals/presentation/pages/vitals_monitor_page.dart';
import 'package:orionhealth_health/features/vitals/domain/entities/vital_sign.dart';
import 'package:orionhealth_health/features/vitals/domain/repositories/vital_sign_repository.dart';
import 'package:orionhealth_health/features/health_sharing/infrastructure/ble_sharing_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'utils/video_recorder.dart';

class MockVitalSignRepository extends Mock implements VitalSignRepository {}
class MockBleSharingService extends Mock implements BleSharingService {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockVitalSignRepository mockRepository;
  late MockBleSharingService mockBleService;

  setUpAll(() async {
    await di.configureDependencies();
    di.getIt.allowReassignment = true;
    await initializeDateFormatting('es', null);

    registerFallbackValue(VitalSign(
      type: VitalSignType.heartRate,
      value: 0,
      dateTime: DateTime.now(),
    ));
  });

  setUp(() {
    mockRepository = MockVitalSignRepository();
    mockBleService = MockBleSharingService();

    di.getIt.registerSingleton<VitalSignRepository>(mockRepository);
    di.getIt.registerSingleton<BleSharingService>(mockBleService);

    // Default mocks
    when(() => mockBleService.initialize()).thenAnswer((_) async {});
  });

  tearDown(() {
    // No need to unregister if using allowReassignment in True E2E
  });

  group('Vitals Feature - E2E Tests', () {
    testWidgets('E2E: Full Vitals Flow - Dashboard, Manual Entry, and BLE Monitor', (WidgetTester tester) async {
      final now = DateTime.now();
      final vitals = [
        VitalSign(type: VitalSignType.heartRate, value: 72, dateTime: now),
        VitalSign(type: VitalSignType.bloodPressureSystolic, value: 120, dateTime: now),
        VitalSign(type: VitalSignType.bloodPressureDiastolic, value: 80, dateTime: now),
      ];

      when(() => mockRepository.getLatestVitals()).thenAnswer((_) async => {
        VitalSignType.heartRate: vitals[0],
        VitalSignType.bloodPressureSystolic: vitals[1],
        VitalSignType.bloodPressureDiastolic: vitals[2],
      });
      when(() => mockRepository.getAllVitalSigns()).thenAnswer((_) async => vitals);

      // 1. DASHBOARD VIEW
      await tester.pumpWidget(const MaterialApp(
        home: VitalsPage(),
        locale: Locale('es'),
      ));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'vitals', '01_dashboard');

      expect(find.text('72.0'), findsOneWidget);
      expect(find.text('120/80'), findsOneWidget);
      expect(find.textContaining('RITMO CARDÍACO'), findsOneWidget);

      // 2. MANUAL ENTRY
      await tester.tap(find.text('Agregar Signo Vital'));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'vitals', '02_add_bottom_sheet');

      await tester.enterText(find.widgetWithText(TextField, 'Valor'), '75');

      when(() => mockRepository.saveVitalSign(any())).thenAnswer((_) async {
        final newVital = VitalSign(type: VitalSignType.heartRate, value: 75, dateTime: DateTime.now());
        vitals.add(newVital);
        // Update mocks for refresh
        when(() => mockRepository.getLatestVitals()).thenAnswer((_) async => {
          VitalSignType.heartRate: newVital,
          VitalSignType.bloodPressureSystolic: vitals[1],
          VitalSignType.bloodPressureDiastolic: vitals[2],
        });
        when(() => mockRepository.getAllVitalSigns()).thenAnswer((_) async => vitals);
      });

      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();

      verify(() => mockRepository.saveVitalSign(any())).called(1);
      expect(find.text('75.0'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'vitals', '03_after_manual_entry');

      // 3. NAVIGATION TO MONITOR
      await tester.tap(find.byIcon(Icons.monitor_heart));
      await tester.pumpAndSettle();
      expect(find.byType(VitalsMonitorPage), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'vitals', '04_monitor_page_empty');

      // 4. BLE SCANNING
      final devices = [
        const BleDevice(id: '1', name: 'Polar H10', type: 'Heart Rate Monitor'),
      ];
      when(() => mockBleService.scanForDevices()).thenAnswer((_) async => devices);

      await tester.tap(find.text('Search Devices'));
      await tester.pump(); // Scanning state
      expect(find.text('Scanning...'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'vitals', '05_monitor_scanning');

      await tester.pumpAndSettle();
      expect(find.text('Polar H10'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'vitals', '06_monitor_scan_results');

      // 5. BLE CONNECTION
      when(() => mockBleService.connect('1')).thenAnswer((_) async => true);
      when(() => mockBleService.startMedicalDataStream('1')).thenAnswer((_) async {});

      await tester.tap(find.text('CONNECT'));
      await tester.pumpAndSettle();

      verify(() => mockBleService.connect('1')).called(1);
      verify(() => mockBleService.startMedicalDataStream('1')).called(1);

      // Verification of real-time update might be tricky due to Timer.periodic,
      // but we can check for the status message
      expect(find.text('Connected to Polar H10'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'vitals', '07_monitor_connected');
    });
  });
}
