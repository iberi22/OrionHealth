import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/core/di/injection.dart';
import 'package:orionhealth_health/features/health_record/domain/entities/medical_record.dart';
import 'package:orionhealth_health/features/health_record/domain/repositories/health_record_repository.dart';
import 'package:orionhealth_health/features/health_record/presentation/pages/timeline_page.dart';
import 'package:health_wallet/health_wallet.dart';
import '../../../../core/golden_test_utils.dart';
import 'health_record_mocks.dart';

void main() {
  late MockHealthRecordRepository mockRepository;
  late MockWalletService mockWalletService;

  setUp(() async {
    mockRepository = MockHealthRecordRepository();
    mockWalletService = MockWalletService();

    await getIt.reset();
    getIt.registerSingleton<HealthRecordRepository>(mockRepository);
    getIt.registerSingleton<WalletService>(mockWalletService);
  });

  tearDown(() async {
    await getIt.reset();
  });

  testWidgets('TimelinePage empty state golden test', (tester) async {
    setupGoldenTest(tester);

    when(() => mockRepository.getAllRecords()).thenAnswer((_) async => []);
    when(() => mockWalletService.getTimeline()).thenAnswer((_) async => []);
    when(() => mockWalletService.getAllMedicalConcepts()).thenAnswer((_) async => []);
    when(() => mockWalletService.getDataStatistics()).thenAnswer((_) async => {'labs': 0});

    await tester.pumpWidget(wrapWithMaterial(const TimelinePage()));
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(TimelinePage),
      matchesGoldenFile('goldens/timeline_page_empty.png'),
    );
  });

  testWidgets('TimelinePage with data golden test', (tester) async {
    setupGoldenTest(tester);

    final now = DateTime(2024, 7, 4, 10, 0);

    final records = [
      MedicalRecord(
        date: now.subtract(const Duration(days: 1)),
        type: RecordType.labResult,
        summary: 'Examen de sangre completo',
      ),
    ];

    final events = [
      MedicalEvent(
        remoteId: 'event-1',
        eventType: EventType.appointment,
        description: 'Consulta con Cardiólogo',
        eventDate: now.subtract(const Duration(days: 2)),
        createdAt: now,
        updatedAt: now,
        facility: 'Hospital Central',
      ),
    ];

    final concepts = [
      MedicalConcept(
        remoteId: 'concept-1',
        doctorName: 'García',
        notes: 'Paciente con buena evolución.',
        recommendations: 'Continuar con dieta baja en sodio.',
        conceptDate: now.subtract(const Duration(days: 3)),
        createdAt: now,
        updatedAt: now,
      ),
    ];

    when(() => mockRepository.getAllRecords()).thenAnswer((_) async => records);
    when(() => mockWalletService.getTimeline()).thenAnswer((_) async => events);
    when(() => mockWalletService.getAllMedicalConcepts()).thenAnswer((_) async => concepts);
    when(() => mockWalletService.getDataStatistics()).thenAnswer((_) async => {'labs': 1});

    await tester.pumpWidget(wrapWithMaterial(const TimelinePage()));
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(TimelinePage),
      matchesGoldenFile('goldens/timeline_page_data.png'),
    );
  });
}
