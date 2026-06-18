import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/local_agent/domain/entities/medical_code.dart';
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

    test('initialize completes without error (asset may not exist in test)', () async {
      await repo.initialize();
      // Should complete without exception
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
    });
  });

  group('AssetMedicalRepo search methods', () {
    setUp(() async {
      await repo.initialize();
    });

    test('searchByCode returns null for unknown code', () async {
      final result = await repo.searchByCode('ZZZ999');
      expect(result, isNull);
    });

    test('searchByCodeInStandard returns null for unknown code', () async {
      final result = await repo.searchByCodeInStandard('ZZZ999', 'ICD-10');
      expect(result, isNull);
    });

    test('searchByTerm returns empty when no match', () async {
      final results = await repo.searchByTerm('xyznonexistentterm');
      expect(results, isEmpty);
    });

    test('searchByTermInStandard returns empty when no match', () async {
      final results = await repo.searchByTermInStandard('xyznonexistent', 'ICD-10');
      expect(results, isEmpty);
    });

    test('searchByCategory returns empty for unknown category', () async {
      final results = await repo.searchByCategory('Xenobiology');
      expect(results, isEmpty);
    });

    test('getAllCodes returns all indexed codes', () async {
      final codes = await repo.getAllCodes();
      expect(codes, isA<List<MedicalCode>>());
    });

    test('getAllCodes with standard filter', () async {
      final icdCodes = await repo.getAllCodes(standard: 'ICD-10');
      expect(icdCodes, isA<List<MedicalCode>>());
    });
  });

  group('AssetMedicalRepo utility methods', () {
    setUp(() async {
      await repo.initialize();
    });

    test('checkInteractions returns empty list', () async {
      final interactions = await repo.checkInteractions(['E11', 'I10']);
      expect(interactions, isEmpty);
    });

    test('getSymptomMappings returns a list', () {
      final mappings = repo.getSymptomMappings();
      expect(mappings, isA<List<Map<String, dynamic>>>());
    });
  });
}
