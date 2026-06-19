import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/onboarding/application/sync_cubit.dart';
import 'package:medical_standards/medical_standards.dart';
import 'package:orionhealth_health/features/local_agent/domain/services/vector_store_service.dart';

class MockSyncService extends Mock implements SyncService {}
class MockVectorStoreService extends Mock implements VectorStoreService {}

void main() {
  late SyncCubit cubit;
  late MockSyncService mockSyncService;
  late MockVectorStoreService mockVectorStoreService;

  setUp(() {
    mockSyncService = MockSyncService();
    mockVectorStoreService = MockVectorStoreService();
    cubit = SyncCubit(mockSyncService, mockVectorStoreService);

    registerFallbackValue(SyncService.datasets.first);
  });

  tearDown(() {
    cubit.close();
  });

  group('SyncCubit', () {
    test('initial state is SyncInitial', () {
      expect(cubit.state, isA<SyncInitial>());
    });

    test('syncMedicalStandards success flow', () async {
      when(() => mockSyncService.syncDataset(any()))
          .thenAnswer((_) async => const SyncResult(success: true, datasetName: 'test'));
      when(() => mockVectorStoreService.indexMedicalStandards(force: true))
          .thenAnswer((_) async {});
      when(() => mockSyncService.getSyncStatus())
          .thenAnswer((_) async => 'All synced');

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<SyncInProgress>(), // icd10
          isA<SyncInProgress>(), // loinc
          isA<SyncInProgress>(), // snomed
          isA<SyncInProgress>(), // rxnorm
          isA<SyncInProgress>().having((s) => s.progress, 'progress', 0.9), // indexing
          isA<SyncSuccess>().having((s) => s.status, 'status', 'All synced'),
        ]),
      );

      await cubit.syncMedicalStandards();
      await expectation;

      verify(() => mockSyncService.syncDataset(any())).called(4);
      verify(() => mockVectorStoreService.indexMedicalStandards(force: true)).called(1);
    });

    test('syncMedicalStandards failure flow', () async {
      when(() => mockSyncService.syncDataset(any()))
          .thenAnswer((invocation) async {
            final config = invocation.positionalArguments[0] as SyncConfig;
            if (config.datasetName == 'loinc') {
              return const SyncResult(success: false, datasetName: 'loinc', error: 'Network error');
            }
            return SyncResult(success: true, datasetName: config.datasetName);
          });

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<SyncInProgress>(), // icd10
          isA<SyncInProgress>(), // loinc
          isA<SyncInProgress>(), // snomed
          isA<SyncInProgress>(), // rxnorm
          isA<SyncFailure>().having((s) => s.error, 'error', contains('loinc: Network error')),
        ]),
      );

      await cubit.syncMedicalStandards();
      await expectation;

      verifyNever(() => mockVectorStoreService.indexMedicalStandards(force: true));
    });

    test('syncMedicalStandards unexpected error flow', () async {
      when(() => mockSyncService.syncDataset(any()))
          .thenThrow(Exception('Unexpected crash'));

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<SyncInProgress>(),
          isA<SyncFailure>().having((s) => s.error, 'error', contains('Unexpected crash')),
        ]),
      );

      await cubit.syncMedicalStandards();
      await expectation;
    });
  });
}
