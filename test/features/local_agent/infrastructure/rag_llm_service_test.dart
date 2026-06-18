import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/local_agent/domain/services/vector_store_service.dart';
import 'package:orionhealth_health/features/local_agent/domain/services/llm_adapter.dart';
import 'package:orionhealth_health/features/local_agent/infrastructure/llm_service.dart';
import 'package:orionhealth_health/features/local_agent/infrastructure/rag_llm_service.dart';
import 'package:orionhealth_health/features/medical_research/infrastructure/medical_research_service.dart';
import 'package:orionhealth_health/features/user_profile/domain/repositories/user_profile_repository.dart';

class MockVectorStoreService extends Mock implements VectorStoreService {}
class MockMedicalResearchService extends Mock implements MedicalResearchService {}
class MockUserProfileRepository extends Mock implements UserProfileRepository {}
class MockLlmAdapter extends Mock implements LlmAdapter {}

class FakeUserProfile {
  final bool allowCloudApi;
  FakeUserProfile({this.allowCloudApi = true});
}

void main() {
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

    registerFallbackValue('test-query');
    registerFallbackValue(<String, dynamic>{});
  });

  group('RagLlmService', () {
    test('implements LlmService interface', () {
      expect(service, isA<LlmService>());
    });

    test('generate produces response with context when docs available', () async {
      when(() => mockUserProfileRepo.getUserProfile())
          .thenAnswer((_) async => null);
      when(() => mockVectorStore.search(any()))
          .thenAnswer((_) async => ['ICD-10: E11 Diabetes']);
      when(() => mockAdapter.generate(any())).thenAnswer(
        (_) async => 'Respuesta con contexto local',
      );

      final result = StringBuffer();
      await service.generate('diabetes').forEach(result.write);

      expect(result.toString(), contains('Respuesta con contexto local'));
      verify(() => mockAdapter.generate(argThat(contains('ICD-10')))).called(1);
    });

    test('generate performs research enrichment when few context docs', () async {
      when(() => mockUserProfileRepo.getUserProfile())
          .thenAnswer((_) async => null);
      when(() => mockVectorStore.search(any()))
          .thenAnswer((_) async => ['Single result']);
      when(() => mockResearch.performResearch(any()))
          .thenAnswer((_) async => [
            ResearchResult(
              title: 'Diabetes Study',
              content: 'Latest research on diabetes management',
              source: 'PubMed',
            ),
          ]);
      when(() => mockAdapter.generate(any())).thenAnswer(
        (_) async => 'Respuesta enriquecida con investigación',
      );

      final result = StringBuffer();
      await service.generate('latest diabetes treatments').forEach(result.write);

      expect(result.toString(), contains('Respuesta enriquecida con investigación'));
      verify(() => mockResearch.performResearch(any())).called(1);
    });

    test('generate skips research when enough context docs', () async {
      when(() => mockUserProfileRepo.getUserProfile())
          .thenAnswer((_) async => null);
      when(() => mockVectorStore.search(any()))
          .thenAnswer((_) async => [
            'ICD-10: E11',
            'ICD-10: I10',
            'LOINC: 4548-4',
          ]);
      when(() => mockAdapter.generate(any())).thenAnswer(
        (_) async => 'Respuesta con contexto suficiente',
      );

      final result = StringBuffer();
      await service.generate('medical query').forEach(result.write);

      expect(result.toString(), contains('Respuesta con contexto suficiente'));
      verifyNever(() => mockResearch.performResearch(any()));
    });

    test('generate handles adapter error gracefully', () async {
      when(() => mockUserProfileRepo.getUserProfile())
          .thenAnswer((_) async => null);
      when(() => mockVectorStore.search(any()))
          .thenAnswer((_) async => []);
      when(() => mockAdapter.generate(any())).thenThrow(
        Exception('adapter failure'),
      );

      final result = StringBuffer();
      await service.generate('test').forEach(result.write);

      final response = result.toString();
      expect(response, contains('error al generar la respuesta'));
    });

    test('generate disables research when cloud not allowed', () async {
      when(() => mockUserProfileRepo.getUserProfile())
          .thenAnswer((_) async => UserProfile(
                id: '1',
                allowCloudApi: false,
              ));
      when(() => mockVectorStore.search(any()))
          .thenAnswer((_) async => ['Single result']);
      when(() => mockAdapter.generate(any())).thenAnswer(
        (_) async => 'Respuesta offline',
      );

      final result = StringBuffer();
      await service.generate('test').forEach(result.write);

      verifyNever(() => mockResearch.performResearch(any()));
      expect(result.toString(), contains('Respuesta offline'));
    });
  });
}

/// Dummy user profile for testing.
class UserProfile {
  final String id;
  final bool allowCloudApi;
  UserProfile({required this.id, this.allowCloudApi = true});
}

/// Dummy research result for testing.
class ResearchResult {
  final String title;
  final String content;
  final String source;
  ResearchResult({
    required this.title,
    required this.content,
    required this.source,
  });
}
