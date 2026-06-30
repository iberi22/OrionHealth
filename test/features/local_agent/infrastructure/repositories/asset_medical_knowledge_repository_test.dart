import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/local_agent/domain/repositories/medical_knowledge_repository.dart';
import 'package:orionhealth_health/features/local_agent/infrastructure/repositories/asset_medical_knowledge_repository.dart';

void main() {
  late AssetMedicalKnowledgeRepository repo;

  setUp(() {
    repo = AssetMedicalKnowledgeRepository();
  });

  group('AssetMedicalKnowledgeRepository', () {
    test('implements MedicalKnowledgeRepository interface', () {
      expect(repo, isA<MedicalKnowledgeRepository>());
    });

    test('isInitialized returns false before initialize', () {
      expect(repo.isInitialized, isFalse);
    });

    test('throws StateError when queried before initialize', () {
      expect(
        () => repo.searchByCode('E11'),
        throwsA(isA<StateError>()),
      );
      expect(
        () => repo.searchByTerm('diabetes'),
        throwsA(isA<StateError>()),
      );
      expect(
        () => repo.getAllCodes(),
        throwsA(isA<StateError>()),
      );
    });

    test('initialize completes despite asset not found (throws in test)', () async {
      // In test environment, rootBundle.loadString will throw
      // but the implementation catches and logs errors, continuing gracefully
      await repo.initialize();
      expect(repo.isInitialized, isTrue);
    });

    test('getStats returns proper structure after init', () async {
      await repo.initialize();

      final stats = repo.getStats();
      expect(stats.containsKey('total'), isTrue);
      expect(stats.containsKey('initialized'), isTrue);
      expect(stats['initialized'], isTrue);
      expect(stats.containsKey('perStandard'), isTrue);
      expect(stats.containsKey('indexedTerms'), isTrue);
      expect(stats.containsKey('indexedCategories'), isTrue);
      expect(stats['total'], 0); // No assets loaded in test
    });

    test('searchByCode returns null for unknown code after init', () async {
      await repo.initialize();
      final result = await repo.searchByCode('ZZZ999');
      expect(result, isNull);
    });

    test('searchByCodeInStandard returns null for unknown code', () async {
      await repo.initialize();
      final result = await repo.searchByCodeInStandard('ZZZ999', 'ICD-10');
      expect(result, isNull);
    });

    test('searchByTerm returns empty when no match', () async {
      await repo.initialize();
      final results = await repo.searchByTerm('xyznonexistentterm');
      expect(results, isEmpty);
    });

    test('searchByTermInStandard returns empty when no match', () async {
      await repo.initialize();
      final results = await repo.searchByTermInStandard('xyznonexistent', 'ICD-10');
      expect(results, isEmpty);
    });

    test('searchByCategory returns empty for unknown category', () async {
      await repo.initialize();
      final results = await repo.searchByCategory('Xenobiology');
      expect(results, isEmpty);
    });

    test('getAllCodes returns empty list with no source files', () async {
      await repo.initialize();
      final codes = await repo.getAllCodes();
      expect(codes, isEmpty);
    });

    test('getAllCodes with standard filter returns empty on no files', () async {
      await repo.initialize();
      final codes = await repo.getAllCodes(standard: 'ICD-10');
      expect(codes, isEmpty);
    });

    test('checkInteractions returns empty list', () async {
      await repo.initialize();
      final interactions = await repo.checkInteractions(['E11', 'I10']);
      expect(interactions, isEmpty);
    });

    test('getSymptomMappings returns a list', () async {
      await repo.initialize();
      final mappings = repo.getSymptomMappings();
      expect(mappings, isA<List<Map<String, dynamic>>>());
    });

    test('force re-initialize works', () async {
      await repo.initialize();
      expect(repo.isInitialized, isTrue);

      await repo.initialize(force: true);
      expect(repo.isInitialized, isTrue);
    });
  });
}
