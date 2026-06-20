import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:health_wallet/health_wallet.dart';
import 'package:orionhealth_health/features/health_record/presentation/pages/timeline_page.dart';
import 'package:orionhealth_health/features/health_record/domain/repositories/health_record_repository.dart';
import 'package:orionhealth_health/features/health_record/domain/entities/medical_record.dart';

class MockHealthRecordRepository extends Mock implements HealthRecordRepository {}
class MockWalletService extends Mock implements WalletService {}

void main() {
  late MockHealthRecordRepository mockRepo;
  late MockWalletService mockWalletService;

  setUp(() {
    mockRepo = MockHealthRecordRepository();
    mockWalletService = MockWalletService();

    final getIt = GetIt.instance;
    if (getIt.isRegistered<HealthRecordRepository>()) {
      getIt.unregister<HealthRecordRepository>();
    }
    if (getIt.isRegistered<WalletService>()) {
      getIt.unregister<WalletService>();
    }
    getIt.registerLazySingleton<HealthRecordRepository>(() => mockRepo);
    getIt.registerLazySingleton<WalletService>(() => mockWalletService);
  });

  tearDown(() {
    GetIt.instance.unregister<HealthRecordRepository>();
    GetIt.instance.unregister<WalletService>();
  });

  Widget createWidgetUnderTest() {
    return const MaterialApp(
      home: TimelinePage(),
    );
  }

  group('TimelinePage', () {
    testWidgets('renders loading indicator initially', (tester) async {
      when(() => mockRepo.getAllRecords()).thenAnswer((_) async => []);
      when(() => mockWalletService.getTimeline()).thenAnswer((_) async => []);
      when(() => mockWalletService.getDataStatistics()).thenAnswer((_) async => {'labs': 0});
      when(() => mockWalletService.getAllMedicalConcepts()).thenAnswer((_) async => []);

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders timeline entries from local repository', (tester) async {
      final records = [
        MedicalRecord(
          summary: 'Local Clinical Note',
          type: RecordType.clinicalNote,
          date: DateTime(2023, 10, 1),
        ),
      ];

      when(() => mockRepo.getAllRecords()).thenAnswer((_) async => records);
      when(() => mockWalletService.getTimeline()).thenAnswer((_) async => []);
      when(() => mockWalletService.getDataStatistics()).thenAnswer((_) async => {'labs': 0});
      when(() => mockWalletService.getAllMedicalConcepts()).thenAnswer((_) async => []);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Nota Clínica'), findsOneWidget);
      expect(find.text('Local Clinical Note'), findsOneWidget);
    });

    testWidgets('renders timeline entries from WalletService', (tester) async {
      final now = DateTime.now();
      final events = [
        MedicalEvent(
          remoteId: '1',
          description: 'Remote Medical Event',
          eventDate: now,
          eventType: EventType.wellnessCheck,
          facility: 'Test Hospital',
          createdAt: now,
          updatedAt: now,
        ),
      ];

      when(() => mockRepo.getAllRecords()).thenAnswer((_) async => []);
      when(() => mockWalletService.getTimeline()).thenAnswer((_) async => events);
      when(() => mockWalletService.getDataStatistics()).thenAnswer((_) async => {'labs': 0});
      when(() => mockWalletService.getAllMedicalConcepts()).thenAnswer((_) async => []);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Remote Medical Event'), findsOneWidget);
      expect(find.text('WELLNESSCHECK at Test Hospital'), findsOneWidget);
    });

    testWidgets('renders medical concepts from WalletService', (tester) async {
      final now = DateTime.now();
      final concepts = [
        MedicalConcept(
          remoteId: '1',
          doctorName: 'House',
          notes: 'It is not lupus',
          conceptDate: now,
          recommendations: 'Take some rest',
          createdAt: now,
          updatedAt: now,
        ),
      ];

      when(() => mockRepo.getAllRecords()).thenAnswer((_) async => []);
      when(() => mockWalletService.getTimeline()).thenAnswer((_) async => []);
      when(() => mockWalletService.getDataStatistics()).thenAnswer((_) async => {'labs': 0});
      when(() => mockWalletService.getAllMedicalConcepts()).thenAnswer((_) async => concepts);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Nota de Dr. House'), findsOneWidget);
      expect(find.text('It is not lupus'), findsOneWidget);
      expect(find.text('Rec: Take some rest'), findsOneWidget);
    });

    testWidgets('shows empty message when no data', (tester) async {
      when(() => mockRepo.getAllRecords()).thenAnswer((_) async => []);
      when(() => mockWalletService.getTimeline()).thenAnswer((_) async => []);
      when(() => mockWalletService.getDataStatistics()).thenAnswer((_) async => {'labs': 0});
      when(() => mockWalletService.getAllMedicalConcepts()).thenAnswer((_) async => []);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('No hay eventos en tu historial médico.'), findsOneWidget);
    });

    testWidgets('shows error message on failure', (tester) async {
      when(() => mockRepo.getAllRecords()).thenThrow(Exception('Failed to load'));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.textContaining('Error: Exception: Failed to load'), findsOneWidget);
    });
  });
}
