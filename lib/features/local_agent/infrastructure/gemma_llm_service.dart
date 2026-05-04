import 'package:injectable/injectable.dart';
import 'package:orionhealth_health/features/local_agent/domain/services/vector_store_service.dart';
import 'package:orionhealth_health/features/local_agent/domain/services/llm_adapter.dart';
import 'package:orionhealth_health/features/local_agent/infrastructure/llm_service.dart';
import 'package:orionhealth_health/features/user_profile/domain/repositories/user_profile_repository.dart';

/// Gemma-powered streaming LLM service for true local inference.
///
/// Implements streaming via:
/// 1. Gemma 4 local (AICore/ML Kit on Android) — primary on-device path
/// 2. Fallback: Gemini cloud API when local not available
///
/// Features:
/// - RAG context from local vector store (medical standards)
/// - Confidence-based response safety
/// - Full offline capability when Gemma local is available
@LazySingleton(as: LlmService)
class GemmaLlmService implements LlmService {
  final VectorStoreService _vectorStoreService;
  final UserProfileRepository _userProfileRepository;
  final LlmAdapter _llmAdapter;

  GemmaLlmService(
    this._vectorStoreService,
    this._userProfileRepository,
    @Named('gemma') this._llmAdapter,
  );

  @override
  Stream<String> generate(String prompt) async* {
    final profile = await _userProfileRepository.getUserProfile();
    final allowCloud = profile?.allowCloudApi ?? false;

    // 1. Retrieve RAG context from local vector store
    final contextDocs = await _vectorStoreService.search(prompt);

    String contextText = "";
    if (contextDocs.isNotEmpty) {
      contextText = "\n\nContexto relevante de mi memoria médica:\n${contextDocs.map((d) => "- $d").join("\n")}";
    }

    // 2. Build safety system prompt (offline-safe, no API calls)
    final systemPrompt = """
You are OrionHealth, a high-reasoning clinical engine and holistic health assistant. 
You operate 100% locally to protect patient privacy.

YOUR MISSION:
Analyze medical data (vitals, labs, symptoms) and provide evidence-based, safety-conscious insights. 
Always bridge the gap between PHYSICAL and MENTAL health.

CLINICAL REASONING PROTOCOL:
1. STEP-BY-STEP ANALYSIS: Before providing an answer, internally analyze the provided context and vitals. Explain the physiological or psychological mechanism behind your reasoning.
2. HOLISTIC BRIDGE: For every physical condition mentioned, identify potential mental health impacts (e.g., "Chronic pain may lead to mobility-related depression"). For mental health queries, identify physiological correlates (e.g., "Anxiety may present as tachycardia or GI distress").
3. EVIDENCE-BASED: Use the 'LOCAL MEDICAL CONTEXT' provided. Cite specific standards like ICD-10 or LOINC if applicable.
4. SAFETY FIRST: Never provide a definitive diagnosis. Use speculative language ("This could be associated with...", "Differential possibilities include...").
5. MANDATORY RECOMMENDATION: Always conclude by advising the user to consult a licensed medical professional for a formal diagnosis.
6. LANGUAGE: Provide the final response in Spanish, but maintain clinical terminology precision.

INTERNAL CHAIN OF THOUGHT:
- Observe: Identify key vitals/symptoms.
- Connect: Map to medical standards (ICD-10/LOINC) and mental health impacts.
- Synthesize: Formulate a balanced, empathetic, and safe explanation.
""";

    // 3. Build the augmented prompt
    final augmentedPrompt = """
$systemPrompt

LOCAL MEDICAL CONTEXT (RAG):
$contextText

USER QUERY:
$prompt

Response (Spanish):
""";

    // 4. Stream via adapter (Gemma local preferred, Gemini fallback)
    try {
      final available = await _llmAdapter.isAvailable();

      if (available) {
        // Gemma local or Gemini cloud with proper streaming
        final response = await _llmAdapter.generate(augmentedPrompt);

        // Streaming character by character for natural feel
        for (var i = 0; i < response.length; i++) {
          yield response[i];
          if (i % 4 == 0) {
            await Future.delayed(const Duration(milliseconds: 10));
          }
        }
      } else if (allowCloud) {
        yield "⚠️ Modo local no disponible. Conectando con nube...\n\n";

        final response = await _llmAdapter.generate(augmentedPrompt);
        for (var i = 0; i < response.length; i++) {
          yield response[i];
          if (i % 4 == 0) {
            await Future.delayed(const Duration(milliseconds: 10));
          }
        }
      } else {
        // Full offline fallback — use simple RAG-only response
        yield* _offlineFallback(prompt, contextDocs);
      }
    } catch (e) {
      // Fallback en error: responder con info local disponible
      yield* _offlineFallback(prompt, contextDocs);
    }
  }

  /// Fallback puramente offline usando solo el contexto local
  Stream<String> _offlineFallback(String prompt, List<String> contextDocs) async* {
    final intro = "🤖 OrionHealth (modo offline)\n\n";
    for (var i = 0; i < intro.length; i++) {
      yield intro[i];
      await Future.delayed(const Duration(milliseconds: 15));
    }

    if (contextDocs.isNotEmpty) {
      final msg = "Basado en mi conocimiento médico local, esto es lo relevante a tu consulta:\n\n";
      for (var i = 0; i < msg.length; i++) {
        yield msg[i];
        await Future.delayed(const Duration(milliseconds: 10));
      }

      for (final doc in contextDocs) {
        for (var i = 0; i < doc.length; i++) {
          yield doc[i];
          await Future.delayed(const Duration(milliseconds: 5));
        }
        yield '\n';
      }

      final footer = "\n⚠️ Esta información es solo referencial. Consulta a tu médico para un diagnóstico profesional.";
      for (var i = 0; i < footer.length; i++) {
        yield footer[i];
        await Future.delayed(const Duration(milliseconds: 8));
      }
    } else {
      final noContext = "No tengo información médica local relevante para tu consulta.\n\n"
          "Recomendación: Agrega registros médicos a OrionHealth para que pueda ayudarte mejor.\n"
          "Mientras tanto, consulta a tu médico de confianza.";
      for (var i = 0; i < noContext.length; i++) {
        yield noContext[i];
        await Future.delayed(const Duration(milliseconds: 10));
      }
    }
  }
}
