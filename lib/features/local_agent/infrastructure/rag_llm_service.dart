import 'package:injectable/injectable.dart';
import 'package:orionhealth_health/features/local_agent/domain/services/vector_store_service.dart';
import 'package:orionhealth_health/features/local_agent/infrastructure/llm_service.dart';
import 'package:orionhealth_health/features/local_agent/domain/services/llm_adapter.dart';
import 'package:orionhealth_health/features/medical_research/infrastructure/medical_research_service.dart';
import 'package:orionhealth_health/features/user_profile/domain/repositories/user_profile_repository.dart';

@LazySingleton(as: LlmService)
class RagLlmService implements LlmService {
  final VectorStoreService _vectorStoreService;
  final MedicalResearchService _medicalResearchService;
  final UserProfileRepository _userProfileRepository;
  final LlmAdapter _llmAdapter;

  RagLlmService(
    this._vectorStoreService,
    this._medicalResearchService,
    this._userProfileRepository,
    @Named('gemma') this._llmAdapter,
  );

  @override
  Stream<String> generate(String prompt) async* {
    final profile = await _userProfileRepository.getUserProfile();
    final allowCloud = profile?.allowCloudApi ?? true;

    // 1. Retrieve relevant context from local vector store
    final contextDocs = await _vectorStoreService.search(prompt);

    String contextText = "";
    if (contextDocs.isNotEmpty) {
      contextText = "\n\nContexto relevante de mi memoria:\n${contextDocs.map((d) => "- $d").join("\n")}";
    }

    // 2. Medical Research Enrichment (Web Search + Scraping)
    String researchText = "";
    if (contextDocs.length < 2) {
      if (allowCloud) {
        final research = await _medicalResearchService.performResearch(prompt);
        if (research.isNotEmpty) {
          researchText = "\n\nInvestigación médica externa:\n${research.take(2).map((r) => "- ${r.title}: ${r.content} (Fuente: ${r.source})").join("\n")}";
        }
      }
    }

    // 3. Construct Augmented Prompt
    final augmentedPrompt = """
Eres un asistente médico inteligente y seguro llamado OrionHealth.
Tu objetivo es ayudar al usuario con su consulta basándote en la información proporcionada.

INFORMACIÓN DE CONTEXTO:
$contextText
$researchText

CONSULTA DEL USUARIO:
$prompt

Instrucciones:
1. Sé conciso y profesional.
2. Si usas información del contexto, menciónalo.
3. No des diagnósticos definitivos si la confianza es baja.
4. Recomienda siempre consultar a un profesional de salud.
5. Responde en el idioma en que se te consultó (español por defecto).

Respuesta:
""";

    // 4. Real generation via local/cloud adapter
    try {
      final response = await _llmAdapter.generate(augmentedPrompt);

      // Yielding character by character to maintain the stream effect
      for (var i = 0; i < response.length; i++) {
        yield response[i];
      }
    } catch (e) {
      yield "Lo siento, hubo un error al generar la respuesta: $e";
    }
  }
}
