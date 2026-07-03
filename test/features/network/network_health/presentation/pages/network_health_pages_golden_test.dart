import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/core/di/injection.dart';
import 'package:orionhealth_health/features/about/presentation/widgets/mission_section.dart';
import 'package:orionhealth_health/features/doctor_verification/presentation/widgets/rating_dialog.dart';
import 'package:orionhealth_health/features/medical_research/presentation/pages/standards_viewer_page.dart';
import 'package:orionhealth_health/features/health_record/presentation/pages/timeline_page.dart';
import 'package:orionhealth_health/features/health_record/domain/repositories/health_record_repository.dart';
import 'package:health_wallet/health_wallet.dart';
import '../../../../../core/golden_test_utils.dart';

class MockHealthRecordRepository extends Mock implements HealthRecordRepository {}
class MockWalletService extends Mock implements WalletService {}

void main() {
  late MockHealthRecordRepository mockHealthRecordRepo;
  late MockWalletService mockWalletService;

  setUpAll(() {
    getIt.allowReassignment = true;
  });

  setUp(() {
    mockHealthRecordRepo = MockHealthRecordRepository();
    mockWalletService = MockWalletService();

    getIt.registerSingleton<HealthRecordRepository>(mockHealthRecordRepo);
    getIt.registerSingleton<WalletService>(mockWalletService);

    when(() => mockHealthRecordRepo.getAllRecords()).thenAnswer((_) async => []);
    when(() => mockWalletService.getTimeline()).thenAnswer((_) async => []);
    when(() => mockWalletService.getDataStatistics()).thenAnswer((_) async => {'labs': 0});
    when(() => mockWalletService.getAllMedicalConcepts()).thenAnswer((_) async => []);
  });

  tearDown(() {
    getIt.unregister<HealthRecordRepository>();
    getIt.unregister<WalletService>();
  });

  group('Network Health Golden Tests', () {
    testWidgets('MissionSection', (tester) async {
      setupGoldenTest(tester);
      await tester.pumpWidget(wrapWithMaterial(
        const Scaffold(
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: MissionSection(
                missionStatement: 'Test Mission',
                values: ['Value 1', 'Value 2'],
                activities: ['Activity 1', 'Activity 2'],
              ),
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(MissionSection),
        matchesGoldenFile("../../../../../golden/reference/mission_section.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('RatingDialog', (tester) async {
      setupGoldenTest(tester);
      await tester.pumpWidget(wrapWithMaterial(
        Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => RatingDialog(
                      doctorId: '123',
                      onSubmitted: (_) {},
                    ),
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      ));

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(RatingDialog),
        matchesGoldenFile("../../../../../golden/reference/rating_dialog.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('StandardsViewerPage', (tester) async {
      setupGoldenTest(tester);
      await tester.pumpWidget(wrapWithMaterial(const StandardsViewerPage()));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(StandardsViewerPage),
        matchesGoldenFile("../../../../../golden/reference/standards_viewer_page.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('TimelinePage', (tester) async {
      setupGoldenTest(tester);
      await tester.pumpWidget(wrapWithMaterial(const TimelinePage()));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(TimelinePage),
        matchesGoldenFile("../../../../../golden/reference/timeline_page.png"),
      );
      resetGoldenTest(tester);
    });
  });
}
