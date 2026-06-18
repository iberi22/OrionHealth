import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/local_agent/domain/entities/medical_code.dart';
import 'package:orionhealth_health/features/local_agent/domain/repositories/medical_knowledge_repository.dart';

/// Minimal concrete implementation for testing the abstract interface.
class TestMedicalKnowledgeRepository implements MedicalKnowledgeRepository {
  final List<MedicalCode> _codes = [];
  bool _initialized = false;

  @override
  bool get isInitialized => _initialized;

  @override
  Future<void> initialize({bool force = false}) async {
    if (_initialized && !force) return;
    _initialized = true;
  }

  @override
  Future<MedicalCode?> searchByCode(String code) async {
    _ensureInitialized();
    try {
      return _codes.firstWhere(
        (c) => c.code.toLowerCase() == code.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<MedicalCode?> searchByCodeInStandard(
    String code,
    String standard,
  ) async {
    _ensureInitialized();
    try {
      return _codes.firstWhere(
        (c) =>
            c.code.toLowerCase() == code.toLowerCase() &&
            c.standard == standard,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<MedicalCode>> searchByTerm(String searchTerm) async {
    _ensureInitialized();
    final term = searchTerm.toLowerCase();
    return _codes.where((c) =>
      c.displayName.toLowerCase().contains(term) ||
      c.searchTerms.any((s) => s.toLowerCase().contains(term)) ||
      c.category.toLowerCase().contains(term)
    ).toList();
  }

  @override
  Future<List<MedicalCode>> searchByTermInStandard(
    String searchTerm,
    String standard,
  ) async {
    _ensureInitialized();
    final results = await searchByTerm(searchTerm);
    return results.where((c) => c.standard == standard).toList();
  }

  @override
  Future<List<MedicalCode>> searchByCategory(String category) async {
    _ensureInitialized();
    return _codes.where((c) =>
      c.category.toLowerCase() == category.toLowerCase()
    ).toList();
  }

  @override
  Future<List<MedicalCode>> getAllCodes({String? standard}) async {
    _ensureInitialized();
    if (standard != null) {
      return _codes.where((c) => c.standard == standard).toList();
    }
    return List.unmodifiable(_codes);
  }

  @override
  Map<String, dynamic> getStats() {
    return {
      'total': _codes.length,
      'initialized': _initialized,
    };
  }

  @override
  Future<List<Map<String, dynamic>>> checkInteractions(List<String> drugCodes) async {
    return [];
  }

  @override
  List<Map<String, dynamic>> getSymptomMappings() {
    return [];
  }

  void addCode(MedicalCode code) => _codes.add(code);

  void _ensureInitialized() {
    if (!_initialized) {
      throw StateError('Repository not initialized');
    }
  }
}

void main() {
  late TestMedicalKnowledgeRepository repo;
  late MedicalCode diabetesCode;
  late MedicalCode hypertensionCode;

  setUp(() {
    repo = TestMedicalKnowledgeRepository();
    diabetesCode = MedicalCode(
      code: 'E11',
      displayName: 'Type 2 diabetes mellitus',
      category: 'Endocrine',
      standard: 'ICD-10',
      searchTerms: ['diabetes', 'tipo 2', 'azúcar en sangre'],
    );
    hypertensionCode = MedicalCode(
      code: 'I10',
      displayName: 'Essential hypertension',
      category: 'Cardiovascular',
      standard: 'ICD-10',
      searchTerms: ['hipertensión', 'presión arterial'],
    );
  });

  group('MedicalKnowledgeRepository interface', () {
    test('isInitialized returns false before initialize', () {
      expect(repo.isInitialized, isFalse);
    });

    test('isInitialized returns true after initialize', () async {
      await repo.initialize();
      expect(repo.isInitialized, isTrue);
    });

    test('initialize with force=true resets state', () async {
      await repo.initialize();
      expect(repo.isInitialized, isTrue);
      await repo.initialize(force: true);
      expect(repo.isInitialized, isTrue);
    });

    test('throws StateError when queried before initialization', () {
      expect(() => repo.searchByCode('E11'), throwsA(isA<StateError>()));
      expect(() => repo.searchByTerm('diabetes'), throwsA(isA<StateError>()));
      expect(() => repo.getAllCodes(), throwsA(isA<StateError>()));
    });
  });

  group('searchByCode', () {
    test('returns code when found', () async {
      await repo.initialize();
      repo.addCode(diabetesCode);

      final result = await repo.searchByCode('E11');
      expect(result, isNotNull);
      expect(result!.displayName, 'Type 2 diabetes mellitus');
    });

    test('is case-insensitive', () async {
      await repo.initialize();
      repo.addCode(diabetesCode);

      final result = await repo.searchByCode('e11');
      expect(result, isNotNull);
    });

    test('returns null when code not found', () async {
      await repo.initialize();
      final result = await repo.searchByCode('Z999');
      expect(result, isNull);
    });
  });

  group('searchByCodeInStandard', () {
    test('returns code when found in specified standard', () async {
      await repo.initialize();
      repo.addCode(diabetesCode);

      final result = await repo.searchByCodeInStandard('E11', 'ICD-10');
      expect(result, isNotNull);
      expect(result!.standard, 'ICD-10');
    });

    test('returns null when code is in different standard', () async {
      await repo.initialize();
      repo.addCode(diabetesCode);

      final result = await repo.searchByCodeInStandard('E11', 'SNOMED');
      expect(result, isNull);
    });
  });

  group('searchByTerm', () {
    test('finds codes matching display name', () async {
      await repo.initialize();
      repo.addCode(diabetesCode);

      final results = await repo.searchByTerm('diabetes');
      expect(results, isNotEmpty);
      expect(results.first.code, 'E11');
    });

    test('finds codes matching search terms', () async {
      await repo.initialize();
      repo.addCode(hypertensionCode);

      final results = await repo.searchByTerm('hipertensión');
      expect(results, isNotEmpty);
    });

    test('returns empty list when no match', () async {
      await repo.initialize();
      repo.addCode(diabetesCode);

      final results = await repo.searchByTerm('cancer');
      expect(results, isEmpty);
    });

    test('is case-insensitive', () async {
      await repo.initialize();
      repo.addCode(diabetesCode);

      final results = await repo.searchByTerm('DIABETES');
      expect(results, isNotEmpty);
    });
  });

  group('searchByTermInStandard', () {
    test('filters results by standard', () async {
      await repo.initialize();
      repo.addCode(diabetesCode);
      repo.addCode(MedicalCode(
        code: '73211009',
        displayName: 'Diabetes mellitus',
        category: 'Endocrine',
        standard: 'SNOMED',
        searchTerms: ['diabetes'],
      ));

      final icdResults = await repo.searchByTermInStandard('diabetes', 'ICD-10');
      expect(icdResults, hasLength(1));
      expect(icdResults.first.code, 'E11');

      final snomedResults = await repo.searchByTermInStandard('diabetes', 'SNOMED');
      expect(snomedResults, hasLength(1));
      expect(snomedResults.first.standard, 'SNOMED');
    });
  });

  group('searchByCategory', () {
    test('finds codes by category', () async {
      await repo.initialize();
      repo.addCode(diabetesCode);
      repo.addCode(hypertensionCode);

      final results = await repo.searchByCategory('Endocrine');
      expect(results, hasLength(1));
      expect(results.first.code, 'E11');
    });
  });

  group('getAllCodes', () {
    test('returns all codes when no standard filter', () async {
      await repo.initialize();
      repo.addCode(diabetesCode);
      repo.addCode(hypertensionCode);

      final all = await repo.getAllCodes();
      expect(all, hasLength(2));
    });

    test('filters by standard when specified', () async {
      await repo.initialize();
      repo.addCode(diabetesCode);
      repo.addCode(MedicalCode(
        code: '250.00',
        displayName: 'Diabetes mellitus',
        category: 'Endocrine',
        standard: 'RxNorm',
      ));

      final icdCodes = await repo.getAllCodes(standard: 'ICD-10');
      expect(icdCodes, hasLength(1));

      final rxCodes = await repo.getAllCodes(standard: 'RxNorm');
      expect(rxCodes, hasLength(1));
    });
  });

  group('getStats', () {
    test('returns stats map', () async {
      await repo.initialize();
      repo.addCode(diabetesCode);

      final stats = repo.getStats();
      expect(stats['total'], 1);
      expect(stats['initialized'], isTrue);
    });
  });

  group('checkInteractions', () {
    test('returns empty list for test implementation', () async {
      await repo.initialize();
      final interactions = await repo.checkInteractions(['E11', 'I10']);
      expect(interactions, isEmpty);
    });
  });

  group('getSymptomMappings', () {
    test('returns empty list for test implementation', () {
      expect(repo.getSymptomMappings(), isEmpty);
    });
  });
}
