import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:orionhealth_health/features/vitals/presentation/pages/vitals_page.dart';
import 'package:orionhealth_health/features/vitals/presentation/pages/vitals_monitor_page.dart';
import 'package:orionhealth_health/features/vitals/domain/repositories/vital_sign_repository.dart';
import 'package:orionhealth_health/features/vitals/domain/entities/vital_sign.dart';
import 'package:orionhealth_health/features/health_sharing/infrastructure/ble_sharing_service.dart';
import '../../../core/golden_test_utils.dart';

class MockVitalSignRepository extends Mock implements VitalSignRepository {}
class MockBleSharingService extends Mock implements BleSharingService {}

void main() {
  late MockVitalSignRepository mockRepository;
  late MockBleSharingService mockBleService;

  setUpAll(() {
    mockRepository = MockVitalSignRepository();
    mockBleService = MockBleSharingService();

    GetIt.I.registerSingleton<VitalSignRepository>(mockRepository);
    GetIt.I.registerSingleton<BleSharingService>(mockBleService);

    // Mock default responses
    when(() => mockRepository.getLatestVitals()).thenAnswer((_) async => {
      VitalSignType.heartRate: VitalSign(
        type: VitalSignType.heartRate,
        value: 72,
        dateTime: DateTime(2025, 1, 1, 10, 0),
      ),
      VitalSignType.temperature: VitalSign(
        type: VitalSignType.temperature,
        value: 36.6,
        dateTime: DateTime(2025, 1, 1, 10, 0),
      ),
      VitalSignType.spO2: VitalSign(
        type: VitalSignType.spO2,
        value: 98,
        dateTime: DateTime(2025, 1, 1, 10, 0),
      ),
      VitalSignType.bloodPressureSystolic: VitalSign(
        type: VitalSignType.bloodPressureSystolic,
        value: 120,
        dateTime: DateTime(2025, 1, 1, 10, 0),
      ),
      VitalSignType.bloodPressureDiastolic: VitalSign(
        type: VitalSignType.bloodPressureDiastolic,
        value: 80,
        dateTime: DateTime(2025, 1, 1, 10, 0),
      ),
    });

    when(() => mockRepository.getAllVitalSigns()).thenAnswer((_) async => [
      VitalSign(
        type: VitalSignType.heartRate,
        value: 72,
        dateTime: DateTime(2025, 1, 1, 10, 0),
      ),
      VitalSign(
        type: VitalSignType.heartRate,
        value: 75,
        dateTime: DateTime(2025, 1, 1, 09, 0),
      ),
    ]);

    when(() => mockBleService.initialize()).thenAnswer((_) async => {});
  });

  tearDownAll(() {
    GetIt.I.reset();
  });

  group('Vitals Golden Tests', () {
    testWidgets('Vitals Page', (tester) async {
      setupGoldenTest(tester);

      await tester.pumpWidget(wrapWithMaterial(const VitalsPage()));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(VitalsPage),
        matchesGoldenFile("../../../golden/reference/vitals_page.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('Vitals Monitor Page', (tester) async {
      setupGoldenTest(tester);

      await tester.pumpWidget(wrapWithMaterial(const VitalsMonitorPage()));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(VitalsMonitorPage),
        matchesGoldenFile("../../../golden/reference/vitals_monitor_page.png"),
      );
      resetGoldenTest(tester);
    });
  });
}
