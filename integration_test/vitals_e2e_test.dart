import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:orionhealth_health/core/di/injection.dart' as di;
import 'package:orionhealth_health/features/vitals/presentation/pages/vitals_page.dart';
import 'package:orionhealth_health/features/vitals/domain/entities/vital_sign.dart';
import 'package:orionhealth_health/features/vitals/domain/repositories/vital_sign_repository.dart';
import 'package:orionhealth_health/features/health_sharing/infrastructure/ble_sharing_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:orionhealth_health/l10n/app_localizations.dart';
import 'utils/video_recorder.dart';

class MockVitalSignRepository extends Mock implements VitalSignRepository {}
class MockBleSharingService extends Mock implements BleSharingService {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockVitalSignRepository mockRepository;
  late MockBleSharingService mockBleService;

  setUpAll(() async {
    await di.configureDependencies();
    registerFallbackValue(VitalSign(
      type: VitalSignType.heartRate,
      value: 0,
      dateTime: DateTime.now(),
    ));
  });

  setUp(() {
    di.getIt.allowReassignment = true;
    mockRepository = MockVitalSignRepository();
    mockBleService = MockBleSharingService();

    di.getIt.registerSingleton<VitalSignRepository>(mockRepository);
    di.getIt.registerSingleton<BleSharingService>(mockBleService);

    // Default mocks
    when(() => mockBleService.initialize()).thenAnswer((_) async {});
  });

  Widget createVitalsPage() {
    return MaterialApp(
      home: const VitalsPage(),
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

  group('Vitals Flow - E2E Tests', () {
    testWidgets('E2E: Vitals History and Monitor Flow', (WidgetTester tester) async {
      // Step 2 & 3: VitalsPage History and Manual Entry
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

      await tester.pumpWidget(createVitalsPage());
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'vitals', '01_initial_dashboard');

      expect(find.text('72.0'), findsOneWidget);
      expect(find.text('120/80'), findsOneWidget);

      // Manual Entry
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(find.text('Agregar Signo Vital'), findsOneWidget);

      await tester.enterText(find.widgetWithText(TextField, 'Valor'), '75');

      when(() => mockRepository.saveVitalSign(any())).thenAnswer((_) async {
        vitals.add(VitalSign(type: VitalSignType.heartRate, value: 75, dateTime: DateTime.now()));
        when(() => mockRepository.getLatestVitals()).thenAnswer((_) async => {
          VitalSignType.heartRate: vitals.last,
          VitalSignType.bloodPressureSystolic: vitals[1],
          VitalSignType.bloodPressureDiastolic: vitals[2],
        });
        when(() => mockRepository.getAllVitalSigns()).thenAnswer((_) async => vitals);
      });

      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();

      verify(() => mockRepository.saveVitalSign(any())).called(1);
      expect(find.text('75.0'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'vitals', '02_added_manual');

      // Step 4 & 5: VitalsMonitorPage Navigation and BLE Flow
      await tester.tap(find.byIcon(Icons.monitor_heart));
      await tester.pumpAndSettle();

      expect(find.text('Vitals Monitor'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'vitals', '03_monitor_initial');

      when(() => mockBleService.scanForDevices()).thenAnswer((_) async => [
        const BleDevice(id: '1', name: 'Pulse Oximeter', type: 'Pulse Oximeter'),
      ]);

      await tester.tap(find.text('Search Devices'));
      await tester.pump(); // Start scan
      expect(find.text('Scanning...'), findsOneWidget);

      await tester.pumpAndSettle(); // Finish scan
      expect(find.text('Pulse Oximeter'), findsOneWidget);

      when(() => mockBleService.connect('1')).thenAnswer((_) async => true);
      when(() => mockBleService.startMedicalDataStream('1')).thenAnswer((_) async {});

      await tester.tap(find.text('CONNECT'));
      await tester.pumpAndSettle();

      expect(find.text('Connected to Pulse Oximeter'), findsOneWidget);

      // Wait for simulated data stream (Timer.periodic in VitalsMonitorPage)
      await tester.pump(const Duration(seconds: 2));
      expect(find.textContaining('BPM'), findsOneWidget);
      // Since it's a simulated fluctuation, any number is fine, but we expect it not to be '--'
      expect(find.text('--'), findsNothing);

      await VideoRecorder.recordStep(tester, 'vitals', '04_monitor_connected');
    });
  });
}
