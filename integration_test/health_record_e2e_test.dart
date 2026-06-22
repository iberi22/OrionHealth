import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:orionhealth_health/core/di/injection.dart';
import 'package:orionhealth_health/features/health_record/presentation/pages/timeline_page.dart';
import 'package:orionhealth_health/features/health_record/domain/repositories/health_record_repository.dart';
import 'package:orionhealth_health/features/health_record/domain/entities/medical_record.dart';
import 'package:health_wallet/health_wallet.dart';
import 'package:mocktail/mocktail.dart';
import 'utils/video_recorder.dart';

class MockHealthRecordRepository extends Mock implements HealthRecordRepository {}
class MockWalletService extends Mock implements WalletService {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockHealthRecordRepository mockRepo;
  late MockWalletService mockWallet;

  setUp(() {
    mockRepo = MockHealthRecordRepository();
    mockWallet = MockWalletService();
    getIt.registerSingleton<HealthRecordRepository>(mockRepo);
    getIt.registerSingleton<WalletService>(mockWallet);
  });

  tearDown(() {
    getIt.unregister<HealthRecordRepository>();
    getIt.unregister<WalletService>();
  });

  group('Health Record Flow - E2E Tests', () {
    testWidgets('E2E: Timeline View with Data', (WidgetTester tester) async {
      final records = [
        MedicalRecord(
          id: 1,
          type: RecordType.labResult,
          summary: 'Blood test results',
          date: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];

      when(() => mockRepo.getAllRecords()).thenAnswer((_) async => records);
      when(() => mockWallet.getTimeline()).thenAnswer((_) async => []);
      when(() => mockWallet.getDataStatistics()).thenAnswer((_) async => {'labs': 0});
      when(() => mockWallet.getAllMedicalConcepts()).thenAnswer((_) async => []);

      await tester.pumpWidget(const MaterialApp(home: TimelinePage()));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'health_record', '01_timeline');

      expect(find.text('Resultado de Laboratorio'), findsOneWidget);
      expect(find.text('Blood test results'), findsOneWidget);
    });
  });
}
