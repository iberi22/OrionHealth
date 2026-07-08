import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:orionhealth_health/features/vitals/presentation/pages/vitals_monitor_page.dart';
import 'package:orionhealth_health/features/health_sharing/infrastructure/ble_sharing_service.dart';
import '../../../../core/golden_test_utils.dart';

class MockBleSharingService extends Mock implements BleSharingService {}

void main() {
  late MockBleSharingService mockBleService;

  setUpAll(() {
    mockBleService = MockBleSharingService();

    GetIt.I.registerSingleton<BleSharingService>(mockBleService);

    when(() => mockBleService.initialize()).thenAnswer((_) async {});
    when(() => mockBleService.scanForDevices()).thenAnswer((_) async => []);
    when(() => mockBleService.connect(any())).thenAnswer((_) async => true);
    when(() => mockBleService.startMedicalDataStream(any())).thenAnswer((_) => {});
  });

  tearDownAll(() {
    GetIt.I.reset();
  });

  group('Vitals Monitor Page Golden Tests', () {
    testWidgets('Vitals Monitor Page - initial state (no devices)', (tester) async {
      setupGoldenTest(tester);

      await tester.pumpWidget(wrapWithMaterial(const VitalsMonitorPage()));
      await tester.pump();

      await expectLater(
        find.byType(VitalsMonitorPage),
        matchesGoldenFile('goldens/vitals_monitor_page_initial.png'),
      );
      resetGoldenTest(tester);
    });
  });
}
