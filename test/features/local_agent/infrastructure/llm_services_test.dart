import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/local_agent/domain/services/llm_adapter.dart';
import 'package:orionhealth_health/features/local_agent/domain/services/vector_store_service.dart';
import 'package:orionhealth_health/features/local_agent/infrastructure/gemma_llm_service.dart';
import 'package:orionhealth_health/features/local_agent/infrastructure/rag_llm_service.dart';
import 'package:orionhealth_health/features/local_agent/infrastructure/mock_llm_service.dart';
import 'package:orionhealth_health/features/medical_research/infrastructure/medical_research_service.dart';
import 'package:orionhealth_health/features/user_profile/domain/entities/user_profile.dart';
import 'package:orionhealth_health/features/user_profile/domain/repositories/user_profile_repository.dart';

class MockVectorStoreService extends Mock implements VectorStoreService {}

class MockLlmAdapter extends Mock implements LlmAdapter {}

class MockUserProfileRepository extends Mock implements UserProfileRepository {}

class MockMedicalResearchService extends Mock
    implements MedicalResearchService {}

void main() {
  group('MockLlmService', () {
    test('generate streams mock response', () async {
      final service = MockLlmService();
      final result = StringBuffer();

      await service.generate('Test prompt').forEach((char) {
        result.write(char);
      });

      expect(result.toString(), contains('mock response'));
      expect(result.toString(), contains('Test prompt'));
      expect(result.toString(), contains('Orion AI'));
    });
  });

  group('GemmaLlmService', () {
    late MockVectorStoreService mockVectorStore;
    late MockUserProfileRepository mockUserProfileRepo;
    late MockLlmAdapter mockAdapter;
    late GemmaLlmService service;

    setUp(() {
      mockVectorStore = MockVectorStoreService();
      mockUserProfileRepo = MockUserProfileRepository();
      mockAdapter = MockLlmAdapter();

      service = GemmaLlmService(
        mockVectorStore,
        mockUserProfileRepo,
        mockAdapter,
      );

      // Default mocks
      when(() => mockVectorStore.search(any())).thenAnswer((_) async => []);
      when(() => mockAdapter.isAvailable()).thenAnswer((_) async => true);
      when(
        () => mockAdapter.generate(any()),
      ).thenAnswer((_) async => 'Respuesta cl\u00ednica: presi\u00f3n normal.');
    });

    test('generate streams complete response from adapter', () async {
      final mockProfile = UserProfile(allowCloudApi: false);
      when(
        () => mockUserProfileRepo.getUserProfile(),
      ).thenAnswer((_) async => mockProfile);

      final result = StringBuffer();
      await service.generate('presi\u00f3n').forEach((char) {
        result.write(char);
      });

      expect(result.toString(), contains('Respuesta cl\u00ednica'));
    });

    test('generate uses vector store search results', () async {
      when(
        () => mockVectorStore.search('hipertensi\u00f3n'),
      ).thenAnswer((_) async => ['ICD-10 I10: Essential Hypertension']);

      final mockProfile = UserProfile(allowCloudApi: false);
      when(
        () => mockUserProfileRepo.getUserProfile(),
      ).thenAnswer((_) async => mockProfile);

      final result = StringBuffer();
      await service.generate('hipertensi\u00f3n').forEach((char) {
        result.write(char);
      });

      // verify vector store was called
      verify(() => mockVectorStore.search('hipertensi\u00f3n')).called(1);
      expect(result.toString(), isNotEmpty);
    });

    test(
      'generate handles adapter unavailable with cloud fallback when allowed',
      () async {
        final mockProfile = UserProfile(allowCloudApi: true);
        when(
          () => mockUserProfileRepo.getUserProfile(),
        ).thenAnswer((_) async => mockProfile);
        when(() => mockAdapter.isAvailable()).thenAnswer((_) async => false);

        final result = StringBuffer();
        await service.generate('dolor de cabeza').forEach((char) {
          result.write(char);
        });

        final response = result.toString();
        expect(response, contains('Modo local no disponible'));
      },
    );
  });

  group('RagLlmService', () {
    late MockVectorStoreService mockVectorStore;
    late MockMedicalResearchService mockResearch;
    late MockUserProfileRepository mockUserProfileRepo;
    late MockLlmAdapter mockAdapter;
    late RagLlmService service;

    setUp(() {
      mockVectorStore = MockVectorStoreService();
      mockResearch = MockMedicalResearchService();
      mockUserProfileRepo = MockUserProfileRepository();
      mockAdapter = MockLlmAdapter();

      service = RagLlmService(
        mockVectorStore,
        mockResearch,
        mockUserProfileRepo,
        mockAdapter,
      );

      when(() => mockVectorStore.search(any())).thenAnswer((_) async => []);
      when(
        () => mockAdapter.generate(any()),
      ).thenAnswer((_) async => 'Respuesta con investigaci\u00f3n.');
      when(
        () => mockResearch.performResearch(any()),
      ).thenAnswer((_) async => []);
    });

    test('generate streams response from adapter', () async {
      when(
        () => mockUserProfileRepo.getUserProfile(),
      ).thenAnswer((_) async => UserProfile(allowCloudApi: true));

      final result = StringBuffer();
      await service.generate('c\u00e1ncer de pulm\u00f3n').forEach((char) {
        result.write(char);
      });

      expect(result.toString(), contains('Respuesta con investigaci\u00f3n'));
    });

    test('generate does research when local context is insufficient', () async {
      when(
        () => mockUserProfileRepo.getUserProfile(),
      ).thenAnswer((_) async => UserProfile(allowCloudApi: true));

      // Fewer than 2 context docs triggers research
      when(
        () => mockVectorStore.search(any()),
      ).thenAnswer((_) async => ['Only one doc']);

      await service.generate('tratamiento').drain();

      verify(() => mockResearch.performResearch('tratamiento')).called(1);
    });

    test(
      'generate skips research when enough local context is available',
      () async {
        when(
          () => mockUserProfileRepo.getUserProfile(),
        ).thenAnswer((_) async => UserProfile(allowCloudApi: true));

        // 2 or more context docs skips research
        when(
          () => mockVectorStore.search(any()),
        ).thenAnswer((_) async => ['Doc1', 'Doc2']);

        await service.generate('diabetes').drain();

        verifyNever(() => mockResearch.performResearch(any()));
      },
    );

    test('generate skips research when cloud is not allowed', () async {
      when(
        () => mockUserProfileRepo.getUserProfile(),
      ).thenAnswer((_) async => UserProfile(allowCloudApi: false));

      await service.generate('fiebre').drain();

      verifyNever(() => mockResearch.performResearch(any()));
    });

    test('generate handles adapter error gracefully', () async {
      when(
        () => mockUserProfileRepo.getUserProfile(),
      ).thenAnswer((_) async => UserProfile(allowCloudApi: false));
      when(() => mockAdapter.generate(any())).thenThrow(Exception('API error'));

      final result = StringBuffer();
      await service.generate('test').forEach((char) {
        result.write(char);
      });

      expect(result.toString(), contains('error'));
    });
  });
}
