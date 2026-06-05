import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/core/services/privacy_anonymizer.dart';
import 'package:orionhealth_health/features/local_agent/infrastructure/adapters/gemini_llm_adapter.dart';
import 'package:orionhealth_health/features/local_agent/infrastructure/adapters/gemini_model_wrapper.dart';
import 'package:orionhealth_health/features/user_profile/domain/repositories/user_profile_repository.dart';
import 'package:orionhealth_health/features/user_profile/domain/entities/user_profile.dart';

class MockPromptScrubber extends Mock implements PromptScrubber {}
class MockUserProfileRepository extends Mock implements UserProfileRepository {}
class MockGeminiModelWrapper extends Mock implements GeminiModelWrapper {}

void main() {
  late GeminiLlmAdapter adapter;
  late MockPromptScrubber mockScrubber;
  late MockUserProfileRepository mockProfileRepo;
  late MockGeminiModelWrapper mockWrapper;

  setUp(() {
    mockScrubber = MockPromptScrubber();
    mockProfileRepo = MockUserProfileRepository();
    mockWrapper = MockGeminiModelWrapper();

    adapter = GeminiLlmAdapter(
      scrubber: mockScrubber,
      userProfileRepository: mockProfileRepo,
      modelWrapper: mockWrapper,
    );

    when(() => mockScrubber.scrub(any(), apiName: any(named: 'apiName')))
        .thenAnswer((invocation) async => invocation.positionalArguments[0] as String);

    when(() => mockProfileRepo.getUserProfile()).thenAnswer((_) async => UserProfile(
      allowCloudApi: true,
    ));
  });

  group('GeminiLlmAdapter', () {
    test('modelName returns gemini-pro', () {
      expect(adapter.modelName, equals('gemini-pro'));
    });

    test('isAvailable returns true when wrapper is provided', () async {
      expect(await adapter.isAvailable(), isTrue);
    });

    test('generate throws SecurityException when allowCloudApi is false', () async {
      when(() => mockProfileRepo.getUserProfile()).thenAnswer((_) async => UserProfile(
        allowCloudApi: false,
      ));

      expect(
        () => adapter.generate('test prompt'),
        throwsA(isA<SecurityException>()),
      );
    });

    test('generate calls wrapper with scrubbed prompt', () async {
      const originalPrompt = 'My email is secret@example.com';
      const scrubbedPrompt = 'My email is [EMAIL]';
      const mockAnswer = 'I received your prompt.';

      when(() => mockScrubber.scrub(originalPrompt, apiName: 'gemini'))
          .thenAnswer((_) async => scrubbedPrompt);

      when(() => mockWrapper.generateContent(scrubbedPrompt))
          .thenAnswer((_) async => mockAnswer);

      final result = await adapter.generate(originalPrompt);

      expect(result, equals(mockAnswer));
      verify(() => mockScrubber.scrub(originalPrompt, apiName: 'gemini')).called(1);
      verify(() => mockWrapper.generateContent(scrubbedPrompt)).called(1);
    });

    test('generate throws Exception on model failure', () async {
      when(() => mockWrapper.generateContent(any())).thenThrow(Exception('API Error'));

      expect(
        () => adapter.generate('test prompt'),
        throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('Failed to generate summary'))),
      );
    });

    test('interface methods return expected defaults', () async {
      expect(await adapter.listInstalledModels(), isEmpty);
      expect(await adapter.isModelInstalled('any'), isFalse);
      expect(() => adapter.installModel(modelId: 'id', url: 'url'), throwsUnsupportedError);

      // Should not throw
      await adapter.uninstallModel('any');
      await adapter.cancelDownload('any');
    });
  });
}
