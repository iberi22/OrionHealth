import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:orionhealth_health/features/vitals/presentation/pages/vitals_page.dart';
import 'package:orionhealth_health/features/vitals/domain/repositories/vital_sign_repository.dart';
import 'package:orionhealth_health/features/vitals/domain/entities/vital_sign.dart';
import 'package:orionhealth_health/features/health_sharing/infrastructure/ble_sharing_service.dart';
import '../../../../core/golden_test_utils.dart';

class MockVitalSignRepository extends Mock implements VitalSignRepository {}
class MockBleSharingService extends Mock implements BleSharingService {}

void main() {
  late MockVitalSignRepository mockRepository;
  late MockBleSharingService mockBleService;

  setUpAll(() {
    mockRepository = MockVitalSignRepository();
    mockBleService = MockBleSharingService();

    final getIt = GetIt.instance;
    getIt.registerSingleton<VitalSignRepository>(mockRepository);
    getIt.registerSingleton<BleSharingService>(mockBleService);

    when(() => mockRepository.getLatestVitals()).thenAnswer((_) async => {});
    when(() => mockRepository.getAllVitalSigns()).thenAnswer((_) async => []);
    when(() => mockBleService.initialize()).thenAnswer((_) async => {});
  });

  testWidgets('Vitals Dashboard Page Golden Test', (tester) async {
    setupGoldenTest(tester);

    await tester.pumpWidget(wrapWithMaterial(const VitalsPage()));
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(VitalsPage),
      matchesGoldenFile('goldens/vitals_page.png'),
    );
    resetGoldenTest(tester);
  });
}
