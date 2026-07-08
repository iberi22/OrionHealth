import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:orionhealth_health/features/vitals/presentation/pages/vitals_page.dart';
import 'package:orionhealth_health/features/vitals/domain/repositories/vital_sign_repository.dart';
import 'package:orionhealth_health/features/vitals/domain/entities/vital_sign.dart';
import '../../../../core/golden_test_utils.dart';

class MockVitalSignRepository extends Mock implements VitalSignRepository {}

void main() {
  late MockVitalSignRepository mockRepository;

  setUpAll(() {
    initializeDateFormatting('es', null);
  });

  setUp(() async {
    mockRepository = MockVitalSignRepository();
    await GetIt.I.reset();
    GetIt.I.registerSingleton<VitalSignRepository>(mockRepository);
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  group('Vitals Page Golden Tests', () {
    testWidgets('Vitals Page - Loading State', (tester) async {
      setupGoldenTest(tester);

      when(() => mockRepository.getLatestVitals()).thenAnswer(
        (_) => Completer<Map<VitalSignType, VitalSign?>>().future,
      );
      when(() => mockRepository.getAllVitalSigns()).thenAnswer(
        (_) => Completer<List<VitalSign>>().future,
      );

      await tester.pumpWidget(wrapWithMaterial(const VitalsPage()));
      await tester.pump();

      await expectLater(
        find.byType(VitalsPage),
        matchesGoldenFile("goldens/vitals_page_loading.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('Vitals Page - Empty State', (tester) async {
      setupGoldenTest(tester);

      when(() => mockRepository.getLatestVitals()).thenAnswer((_) async => {});
      when(() => mockRepository.getAllVitalSigns()).thenAnswer((_) async => []);

      await tester.pumpWidget(wrapWithMaterial(const VitalsPage()));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(VitalsPage),
        matchesGoldenFile("goldens/vitals_page_empty.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('Vitals Page - Loaded State', (tester) async {
      setupGoldenTest(tester);

      final date = DateTime(2026, 7, 8, 10, 0);
      final latestVitals = {
        VitalSignType.heartRate: VitalSign(
          type: VitalSignType.heartRate,
          value: 72,
          dateTime: date,
        ),
        VitalSignType.temperature: VitalSign(
          type: VitalSignType.temperature,
          value: 36.6,
          dateTime: date,
        ),
        VitalSignType.spO2: VitalSign(
          type: VitalSignType.spO2,
          value: 98,
          dateTime: date,
        ),
        VitalSignType.bloodPressureSystolic: VitalSign(
          type: VitalSignType.bloodPressureSystolic,
          value: 120,
          dateTime: date,
        ),
        VitalSignType.bloodPressureDiastolic: VitalSign(
          type: VitalSignType.bloodPressureDiastolic,
          value: 80,
          dateTime: date,
        ),
      };

      final allVitals = [
        VitalSign(
          type: VitalSignType.heartRate,
          value: 72,
          dateTime: date,
        ),
        VitalSign(
          type: VitalSignType.temperature,
          value: 36.6,
          dateTime: date.subtract(const Duration(hours: 2)),
        ),
        VitalSign(
          type: VitalSignType.spO2,
          value: 98,
          dateTime: date.subtract(const Duration(hours: 1)),
        ),
        VitalSign(
          type: VitalSignType.bloodPressureSystolic,
          value: 120,
          dateTime: date,
        ),
        VitalSign(
          type: VitalSignType.bloodPressureDiastolic,
          value: 80,
          dateTime: date,
        ),
      ];

      when(() => mockRepository.getLatestVitals()).thenAnswer((_) async => latestVitals);
      when(() => mockRepository.getAllVitalSigns()).thenAnswer((_) async => allVitals);

      await tester.pumpWidget(wrapWithMaterial(const VitalsPage()));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(VitalsPage),
        matchesGoldenFile("goldens/vitals_page_loaded.png"),
      );
      resetGoldenTest(tester);
    });
  });
}
