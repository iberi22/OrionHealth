import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:orionhealth_health/core/di/injection.dart';
import 'package:orionhealth_health/features/vitals/presentation/pages/vitals_page.dart';
import 'package:orionhealth_health/features/vitals/domain/entities/vital_sign.dart';
import 'package:orionhealth_health/features/vitals/domain/repositories/vital_sign_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'utils/video_recorder.dart';

class MockVitalSignRepository extends Mock implements VitalSignRepository {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockVitalSignRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(VitalSign(
      type: VitalSignType.heartRate,
      value: 0,
      dateTime: DateTime.now(),
    ));
  });

  setUp(() {
    mockRepository = MockVitalSignRepository();
    getIt.registerSingleton<VitalSignRepository>(mockRepository);
  });

  tearDown(() {
    getIt.unregister<VitalSignRepository>();
  });

  group('Vitals Flow - E2E Tests', () {
    testWidgets('E2E: Monitor and Add Vitals', (WidgetTester tester) async {
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

      await tester.pumpWidget(const MaterialApp(home: VitalsPage()));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'vitals', '01_dashboard');

      expect(find.text('72.0'), findsOneWidget);
      expect(find.text('120/80'), findsOneWidget);

      // Add manual
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(TextField, 'Valor'), '75');

      when(() => mockRepository.saveVitalSign(any())).thenAnswer((_) async {
        vitals.add(VitalSign(type: VitalSignType.heartRate, value: 75, dateTime: DateTime.now()));
        // Re-mocking latest vitals
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
      await tester.pumpAndSettle();
      expect(find.text('75.0'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'vitals', '02_added_manual');
    });
  });
}
