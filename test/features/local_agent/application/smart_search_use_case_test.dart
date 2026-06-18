import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/local_agent/application/use_cases/smart_search_use_case.dart';
import 'package:orionhealth_health/features/local_agent/domain/services/vector_store_service.dart';

class MockVectorStoreService extends Mock implements VectorStoreService {}

void main() {
  late MockVectorStoreService mockVectorStore;
  late SmartSearchUseCase useCase;

  setUp(() {
    mockVectorStore = MockVectorStoreService();
    useCase = SmartSearchUseCase(mockVectorStore);

    registerFallbackValue('bm25');
    registerFallbackValue(5);
  });

  group('SmartSearchUseCase', () {
    test('execute returns SmartSearchResult with direct results', () async {
      when(() => mockVectorStore.searchWithReRanking(
            any(),
            limit: any(named: 'limit'),
            strategy: any(named: 'strategy'),
          )).thenAnswer((_) async => ['Result 1', 'Result 2']);
      when(() => mockVectorStore.multiHopSearch(
            any(),
            maxHops: any(named: 'maxHops'),
            topK: any(named: 'topK'),
          )).thenAnswer((_) async => [
        {'node': {'content': 'Hop result 1', 'layer': 0}, 'context': []},
      ]);

      final result = await useCase.execute('diabetes tratamiento');

      expect(result.query, 'diabetes tratamiento');
      expect(result.directResults, hasLength(2));
      expect(result.hierarchicalResults, hasLength(1));
      expect(result.totalResults, 3);
    });

    test('execute uses BM25 strategy for medical terms', () async {
      when(() => mockVectorStore.searchWithReRanking(
            any(),
            limit: any(named: 'limit'),
            strategy: any(named: 'strategy'),
          )).thenAnswer((invocation) async {
        final strategy = invocation.namedArguments[#strategy] as String;
        expect(strategy, 'bm25');
        return ['Medical result'];
      });
      when(() => mockVectorStore.multiHopSearch(
            any(),
            maxHops: any(named: 'maxHops'),
            topK: any(named: 'topK'),
          )).thenAnswer((_) async => []);

      await useCase.execute('diagnóstico de dolor');
    });

    test('execute uses Recency strategy for temporal queries', () async {
      String capturedStrategy = '';
      when(() => mockVectorStore.searchWithReRanking(
            any(),
            limit: any(named: 'limit'),
            strategy: any(named: 'strategy'),
          )).thenAnswer((invocation) async {
        capturedStrategy = invocation.namedArguments[#strategy] as String;
        return ['Recent result'];
      });
      when(() => mockVectorStore.multiHopSearch(
            any(),
            maxHops: any(named: 'maxHops'),
            topK: any(named: 'topK'),
          )).thenAnswer((_) async => []);

      await useCase.execute('resultados recientes');

      expect(capturedStrategy, 'recency');
    });

    test('execute uses Diversity strategy for exploratory queries', () async {
      String capturedStrategy = '';
      when(() => mockVectorStore.searchWithReRanking(
            any(),
            limit: any(named: 'limit'),
            strategy: any(named: 'strategy'),
          )).thenAnswer((invocation) async {
        capturedStrategy = invocation.namedArguments[#strategy] as String;
        return ['Varied result'];
      });
      when(() => mockVectorStore.multiHopSearch(
            any(),
            maxHops: any(named: 'maxHops'),
            topK: any(named: 'topK'),
          )).thenAnswer((_) async => []);

      await useCase.execute('todos los tratamientos');

      expect(capturedStrategy, 'diversity');
    });

    test('execute uses MMR default strategy for general queries', () async {
      String capturedStrategy = '';
      when(() => mockVectorStore.searchWithReRanking(
            any(),
            limit: any(named: 'limit'),
            strategy: any(named: 'strategy'),
          )).thenAnswer((invocation) async {
        capturedStrategy = invocation.namedArguments[#strategy] as String;
        return ['General result'];
      });
      when(() => mockVectorStore.multiHopSearch(
            any(),
            maxHops: any(named: 'maxHops'),
            topK: any(named: 'topK'),
          )).thenAnswer((_) async => []);

      await useCase.execute('que hay de nuevo');

      expect(capturedStrategy, 'mmr');
    });

    test('execute respect limit parameter', () async {
      int capturedLimit = 0;
      when(() => mockVectorStore.searchWithReRanking(
            any(),
            limit: any(named: 'limit'),
            strategy: any(named: 'strategy'),
          )).thenAnswer((invocation) async {
        capturedLimit = invocation.namedArguments[#limit] as int;
        return ['R1'];
      });
      when(() => mockVectorStore.multiHopSearch(
            any(),
            maxHops: any(named: 'maxHops'),
            topK: any(named: 'topK'),
          )).thenAnswer((_) async => []);

      await useCase.execute('dolor', limit: 10);

      expect(capturedLimit, 10);
    });

    test('compareStrategies returns results for all strategies', () async {
      when(() => mockVectorStore.searchWithReRanking(
            any(),
            limit: any(named: 'limit'),
            strategy: any(named: 'strategy'),
          )).thenAnswer((invocation) async {
        final strategy = invocation.namedArguments[#strategy] as String;
        return ['Result from $strategy'];
      });

      final results = await useCase.compareStrategies('fiebre', limit: 3);

      expect(results.keys, containsAll(['bm25', 'mmr', 'diversity', 'recency']));
      expect(results['bm25']!.first, contains('bm25'));
      expect(results['mmr']!.first, contains('mmr'));
    });

    test('compareStrategies handles strategy errors', () async {
      when(() => mockVectorStore.searchWithReRanking(
            any(),
            limit: any(named: 'limit'),
            strategy: any(named: 'strategy'),
          )).thenAnswer((invocation) async {
        final strategy = invocation.namedArguments[#strategy] as String;
        if (strategy == 'mmr') {
          throw Exception('MMR failed');
        }
        return ['Result'];
      });

      final results = await useCase.compareStrategies('test');

      expect(results['mmr']!.first, contains('Error'));
    });

    test('explainStrategy returns explanation for each strategy type', () {
      expect(
        useCase.explainStrategy('diagnóstico'),
        contains('BM25'),
      );
      expect(
        useCase.explainStrategy('reciente'),
        contains('Recency'),
      );
      expect(
        useCase.explainStrategy('todos'),
        contains('Diversity'),
      );
      expect(
        useCase.explainStrategy('hola mundo'),
        contains('MMR'),
      );
    });

    test('hasHierarchicalContext returns true when context is available', () async {
      when(() => mockVectorStore.searchWithReRanking(
            any(),
            limit: any(named: 'limit'),
            strategy: any(named: 'strategy'),
          )).thenAnswer((_) async => ['R1']);
      when(() => mockVectorStore.multiHopSearch(
            any(),
            maxHops: any(named: 'maxHops'),
            topK: any(named: 'topK'),
          )).thenAnswer((_) async => [
        {
          'node': {'content': 'R1', 'layer': 0},
          'context': [{'id': '1', 'content': 'Context'}],
        },
      ]);

      final result = await useCase.execute('test');

      expect(result.hasHierarchicalContext, isTrue);
    });

    test('toJson returns correct map', () {
      final result = SmartSearchResult(
        query: 'test',
        strategy: 'bm25',
        directResults: ['R1'],
        hierarchicalResults: [],
        searchTime: DateTime(2026, 1, 1),
      );

      final json = result.toJson();

      expect(json['query'], 'test');
      expect(json['strategy'], 'bm25');
      expect(json['directResultsCount'], 1);
      expect(json['hierarchicalResultsCount'], 0);
      expect(json['hasContext'], isFalse);
    });
  });
}
