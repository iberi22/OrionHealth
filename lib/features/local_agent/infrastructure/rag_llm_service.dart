import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:orionhealth_health/features/local_agent/domain/services/llm_adapter.dart';
import 'package:orionhealth_health/features/local_agent/domain/services/vector_store_service.dart';
import 'package:orionhealth_health/features/local_agent/infrastructure/adapters/gemini_llm_adapter.dart';
import 'package:orionhealth_health/features/local_agent/infrastructure/llm_service.dart';
import 'package:orionhealth_health/features/local_agent/infrastructure/services/local_llm_service.dart';
import 'package:orionhealth_health/features/user_profile/domain/repositories/user_profile_repository.dart';

enum LlmProvider { mock, local, gemini }

@LazySingleton(as: LlmService)
class RagLlmService implements LlmService {
  final VectorStoreService _vectorStoreService;
  final UserProfileRepository _userProfileRepository;
  final LocalLlmService _localLlmService;
  final GeminiLlmAdapter _geminiLlmAdapter;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  RagLlmService(
    this._vectorStoreService,
    this._userProfileRepository,
    this._localLlmService,
    @Named('gemini') LlmAdapter geminiLlmAdapter,
  ) : _geminiLlmAdapter = geminiLlmAdapter as GeminiLlmAdapter;

  @override
  Stream<String> generate(String prompt) async* {
    // 1. Retrieve relevant context
    final contextDocs = await _vectorStoreService.search(prompt);

    String contextText = "";
    if (contextDocs.isNotEmpty) {
      contextText = "\n\nContexto relevante encontrado:\n${contextDocs.map((d) => "- $d").join("\n")}";
    }

    final fullPrompt = "Context: $contextText\n\nUser Question: $prompt";

    // 2. Determine which provider to use
    final profile = await _userProfileRepository.getUserProfile();
    final providerStr = profile?.llmProvider;
    LlmProvider provider = LlmProvider.mock;

    if (providerStr != null) {
      provider = LlmProvider.values.firstWhere(
        (e) => e.name == providerStr,
        orElse: () => LlmProvider.mock,
      );
    } else {
      // Default logic: gemini if API key configured, else local, else mock
      final apiKey = await _secureStorage.read(key: 'gemini_api_key');
      if (apiKey != null && apiKey.isNotEmpty) {
        provider = LlmProvider.gemini;
      } else {
        // We could check if local is available here, but let's stick to mock as safe default
        provider = LlmProvider.mock;
      }
    }

    // 3. Delegate to the selected provider
    switch (provider) {
      case LlmProvider.gemini:
        final apiKey = await _secureStorage.read(key: 'gemini_api_key');
        if (apiKey != null) {
          _geminiLlmAdapter.updateApiKey(apiKey);
          yield* _geminiLlmAdapter.generateStream(fullPrompt);
        } else {
          yield 'Error: Gemini API key not found in secure storage.';
        }
        break;
      case LlmProvider.local:
        if (profile?.localModelName != null) {
          _localLlmService.setModel(profile!.localModelName!);
        }
        yield* _localLlmService.generate(fullPrompt);
        break;
      case LlmProvider.mock:
        yield* _generateMockResponse(prompt, contextText, contextDocs.length);
    }
  }

  Stream<String> _generateMockResponse(String prompt, String contextText, int contextCount) async* {
    final response = "Entendido (MOCK). Basado en tu consulta '$prompt' y en mi memoria:$contextText\n\n"
        "Aquí está mi análisis:\n"
        "1. He consultado la base de conocimientos local.\n"
        "2. He encontrado $contextCount referencias relevantes.\n"
        "3. Como soy un agente local seguro, tus datos no salen del dispositivo.\n\n"
        "¿Necesitas ayuda con algún registro médico específico?";

    for (var i = 0; i < response.length; i++) {
      await Future.delayed(const Duration(milliseconds: 10));
      yield response[i];
    }
  }
}
