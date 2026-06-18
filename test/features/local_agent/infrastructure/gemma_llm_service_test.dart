import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/local_agent/domain/services/vector_store_service.dart';
import 'package:orionhealth_health/features/local_agent/domain/services/llm_adapter.dart';
import 'package:orionhealth_health/features/user_profile/domain/repositories/user_profile_repository.dart';
import 'package:orionhealth_health/features/user_profile/domain/entities/user_profile.dart';
import 'package:orionhealth_health/features/local_agent/infrastructure/gemma_llm_service.dart';
import 'package:orionhealth_health/features/local_agent/infrastructure/llm_service.dart';

class MockVectorStoreService extends Mock implements VectorStoreService {}
class MockUserProfileRepository extends Mock implements UserProfileRepository {}
class MockLlmAdapter extends Mock implements LlmAdapter {}

void main() {
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

    registerFallbackValue('test-query');
  });

  group('GemmaLlmService', () {
    test('implements LlmService interface', () {
      expect(service, isA<LlmService>());
    });

    test('generate streams full response when adapter is available', () async {
      when(() => mockUserProfileRepo.getUserProfile())
          .thenAnswer((_) async => null);
      when(() => mockVectorStore.search(any()))
          .thenAnswer((_) async => ['Diabetes ICD-10: E11']);
      when(() => mockAdapter.isAvailable()).thenAnswer((_) async => true);
      when(() => mockAdapter.generate(any())).thenAnswer(
        (_) async => 'Respuesta completa de Gemma',
      );

      final result = StringBuffer();
      await service.generate('¿Qué es diabetes?').forEach(result.write);

      expect(result.toString(), contains('Respuesta completa de Gemma'));
    });

    test('generate uses offline fallback when adapter is not available', () async {
      when(() => mockUserProfileRepo.getUserProfile())
          .thenAnswer((_) async => null);
      when(() => mockVectorStore.search(any()))
          .thenAnswer((_) async => ['Diabetes ICD-10: E11']);
      when(() => mockAdapter.isAvailable()).thenAnswer((_) async => false);

      final result = StringBuffer();
      await service.generate('diabetes').forEach(result.write);

      final response = result.toString();
      expect(response, contains('OrionHealth (modo offline)'));
      expect(response, contains('Diabetes ICD-10: E11'));
    });

    test('generate uses offline fallback when adapter throws', () async {
      when(() => mockUserProfileRepo.getUserProfile())
          .thenAnswer((_) async => null);
      when(() => mockVectorStore.search(any()))
          .thenAnswer((_) async => ['Blood pressure']);
      when(() => mockAdapter.isAvailable()).thenAnswer((_) async => true);
      when(() => mockAdapter.generate(any())).thenThrow(
        Exception('Adapter error'),
      );

      final result = StringBuffer();
      await service.generate('blood pressure').forEach(result.write);

      final response = result.toString();
      expect(response, contains('OrionHealth (modo offline)'));
      expect(response, contains('Blood pressure'));
    });

    test('generate offline fallback shows no-context message when no docs', () async {
      when(() => mockUserProfileRepo.getUserProfile())
          .thenAnswer((_) async => null);
      when(() => mockVectorStore.search(any()))
          .thenAnswer((_) async => []);
      when(() => mockAdapter.isAvailable()).thenAnswer((_) async => false);

      final result = StringBuffer();
      await service.generate('unknown query').forEach(result.write);

      final response = result.toString();
      expect(response, contains('No tengo información médica local relevante'));
    });

    test('generate allows cloud when profile allows cloud API', () async {
      when(() => mockUserProfileRepo.getUserProfile())
          .thenAnswer((_) async => UserProfile(allowCloudApi: true));
      when(() => mockVectorStore.search(any()))
          .thenAnswer((_) async => []);
      when(() => mockAdapter.isAvailable()).thenAnswer((_) async => false);

      final result = StringBuffer();
      await service.generate('test').forEach(result.write);

      final response = result.toString();
      expect(response, contains('Modo local no disponible'));
    });
  });
}
