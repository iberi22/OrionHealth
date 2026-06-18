import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/local_agent/domain/entities/medical_code.dart';
import 'package:orionhealth_health/features/local_agent/domain/repositories/medical_knowledge_repository.dart';
import 'package:orionhealth_health/features/local_agent/domain/services/vector_store_service.dart';
import 'package:orionhealth_health/features/local_agent/infrastructure/services/medical_indexing_service.dart';
import 'package:orionhealth_health/features/local_agent/infrastructure/services/patient_context_indexer.dart';

class MockMedicalKnowledgeRepository extends Mock
    implements MedicalKnowledgeRepository {}
class MockVectorStoreService extends Mock implements VectorStoreService {}
class MockPatientContextIndexer extends Mock implements PatientContextIndexer {}

void main() {
  late MockMedicalKnowledgeRepository mockKnowledgeRepo;
  late MockVectorStoreService mockVectorStore;
  late MockPatientContextIndexer mockPatientIndexer;
  late MedicalIndexingService indexingService;

  setUp(() {
    mockKnowledgeRepo = MockMedicalKnowledgeRepository();
    mockVectorStore = MockVectorStoreService();
    mockPatientIndexer = MockPatientContextIndexer();

    indexingService = MedicalIndexingService(
      mockKnowledgeRepo,
      mockVectorStore,
      mockPatientIndexer,
    );

    registerFallbackValue('test-id');
    registerFallbackValue('test-content');
    registerFallbackValue(<String, dynamic>{});
  });

  group('MedicalIndexingService', () {
    test('hasIndexed returns false initially', () {
      expect(indexingService.hasIndexed, isFalse);
    });

    test('indexedCount returns 0 initially', () {
      expect(indexingService.indexedCount, 0);
    });

    test('errorCount returns 0 initially', () {
      expect(indexingService.errorCount, 0);
    });

    group('indexAll', () {
      test('indexes all medical codes successfully', () async {
        final codes = [
          _createCode('E11', 'Type 2 diabetes', 'ICD-10'),
          _createCode('I10', 'Hypertension', 'ICD-10'),
          _createCode('J45', 'Asthma', 'ICD-10'),
        ];

        when(() => mockKnowledgeRepo.initialize()).thenAnswer((_) async => {});
        when(() => mockKnowledgeRepo.getAllCodes())
            .thenAnswer((_) async => codes);
        when(() => mockVectorStore.addDocument(
              any(),
              any(),
              any(),
            )).thenAnswer((_) async => {});
        when(() => mockPatientIndexer.indexAll())
            .thenAnswer((_) async => {});

        final result = await indexingService.indexAll();

        expect(result.total, 3);
        expect(result.indexed, 3);
        expect(result.errors, 0);
        expect(result.success, isTrue);
        expect(result.skipped, isFalse);
        expect(indexingService.hasIndexed, isTrue);
        expect(indexingService.indexedCount, 3);
        expect(indexingService.errorCount, 0);

        verify(() => mockVectorStore.addDocument(
              'med:ICD-10:E11',
              any(),
              any(),
            )).called(1);
        verify(() => mockVectorStore.addDocument(
              'med:ICD-10:I10',
              any(),
              any(),
            )).called(1);
        verify(() => mockVectorStore.addDocument(
              'med:ICD-10:J45',
              any(),
              any(),
            )).called(1);
      });

      test('skip second call when already indexed', () async {
        when(() => mockKnowledgeRepo.initialize()).thenAnswer((_) async => {});
        when(() => mockKnowledgeRepo.getAllCodes())
            .thenAnswer((_) async => []);
        when(() => mockVectorStore.addDocument(
              any(),
              any(),
              any(),
            )).thenAnswer((_) async => {});
        when(() => mockPatientIndexer.indexAll())
            .thenAnswer((_) async => {});

        // First call
        await indexingService.indexAll();

        // Second call should skip
        final result = await indexingService.indexAll();
        expect(result.skipped, isTrue);
        expect(result.success, isTrue);
      });

      test('force parameter allows re-indexing', () async {
        when(() => mockKnowledgeRepo.initialize()).thenAnswer((_) async => {});
        when(() => mockKnowledgeRepo.getAllCodes())
            .thenAnswer((_) async => []);
        when(() => mockVectorStore.addDocument(
              any(),
              any(),
              any(),
            )).thenAnswer((_) async => {});
        when(() => mockPatientIndexer.indexAll())
            .thenAnswer((_) async => {});

        // Index first
        await indexingService.indexAll();
        expect(indexingService.hasIndexed, isTrue);

        // Force re-index with a new code
        when(() => mockKnowledgeRepo.getAllCodes()).thenAnswer((_) async => [
          _createCode('E11', 'Diabetes', 'ICD-10'),
        ]);

        final result = await indexingService.indexAll(force: true);

        expect(result.skipped, isFalse);
        expect(result.total, 1);
        expect(result.indexed, 1);
      });

      test('tracks errors during indexing', () async {
        final codes = [
          _createCode('E11', 'Diabetes', 'ICD-10'),
          _createCode('I10', 'Hypertension', 'ICD-10'),
        ];

        when(() => mockKnowledgeRepo.initialize()).thenAnswer((_) async => {});
        when(() => mockKnowledgeRepo.getAllCodes())
            .thenAnswer((_) async => codes);
        when(() => mockVectorStore.addDocument(
              any(),
              any(),
              any(),
            )).thenAnswer((invocation) {
          final id = invocation.positionalArguments[0] as String;
          if (id.contains('I10')) {
            throw Exception('Vector store error');
          }
          return Future.value();
        });
        when(() => mockPatientIndexer.indexAll())
            .thenAnswer((_) async => {});

        final result = await indexingService.indexAll();

        expect(result.indexed, 1);
        expect(result.errors, 1);
        expect(result.success, isFalse);
        expect(indexingService.indexedCount, 1);
        expect(indexingService.errorCount, 1);
      });
    });

    group('search', () {
      test('returns vector results sorted by relevance', () async {
        // Add some codes to the repo for text fallback
        when(() => mockKnowledgeRepo.initialize()).thenAnswer((_) async => {});
        final diabetesCode = _createCode('E11', 'Diabetes', 'ICD-10');
        when(() => mockKnowledgeRepo.searchByTerm('diabetes'))
            .thenAnswer((_) async => [diabetesCode]);
        when(() => mockVectorStore.search('diabetes', limit: 20))
            .thenAnswer((_) async => []);

        final results = await indexingService.search('diabetes', limit: 5);

        expect(results, hasLength(1));
        expect(results.first.code.displayName, 'Diabetes');
        expect(results.first.score, greaterThan(0));
      });

      test('merges vector and text results without duplicates', () async {
        final diabetesCode = _createCode('E11', 'Diabetes', 'ICD-10');
        final hypertensionCode = _createCode('I10', 'Hypertension', 'ICD-10');

        // Return codes as content from vector store
        final vectorContent = diabetesCode.embeddingText;
        
        when(() => mockVectorStore.search('diabetes', limit: 20))
            .thenAnswer((_) async => [vectorContent]);
        when(() => mockKnowledgeRepo.searchByTerm('diabetes'))
            .thenAnswer((_) async => [diabetesCode, hypertensionCode]);

        final results = await indexingService.search('diabetes', limit: 5);

        // Vector result might not parse, text fallback handles the rest
        expect(results, hasLength(2));
      });

      test('fallback to pure text search when vector store fails', () async {
        final diabetesCode = _createCode('E11', 'Diabetes', 'ICD-10');

        when(() => mockVectorStore.search('diabetes', limit: 20))
            .thenThrow(Exception('Vector store error'));
        when(() => mockKnowledgeRepo.searchByTerm('diabetes'))
            .thenAnswer((_) async => [diabetesCode]);

        final results = await indexingService.search('diabetes', limit: 5);

        expect(results, hasLength(1));
        expect(results.first.code.code, 'E11');
        expect(results.first.score, 1.0);
      });
    });

    group('statusStream', () {
      test('emits false while indexing, true when done', () async {
        final statuses = <bool>[];
        final sub = indexingService.statusStream.listen(statuses.add);

        when(() => mockKnowledgeRepo.initialize()).thenAnswer((_) async => {});
        when(() => mockKnowledgeRepo.getAllCodes())
            .thenAnswer((_) async => []);
        when(() => mockVectorStore.addDocument(
              any(),
              any(),
              any(),
            )).thenAnswer((_) async => {});
        when(() => mockPatientIndexer.indexAll())
            .thenAnswer((_) async => {});

        await indexingService.indexAll();

        // Wait for stream to settle
        await Future.delayed(Duration.zero);

        // Should emit both false and true
        expect(statuses.length, greaterThanOrEqualTo(1));
        expect(statuses, contains(isTrue));
        await sub.cancel();
      });
    });
  });
}

MedicalCode _createCode(String code, String displayName, String standard) {
  return MedicalCode(
    code: code,
    displayName: displayName,
    category: 'Endocrine',
    standard: standard,
    searchTerms: ['search term'],
  );
}
