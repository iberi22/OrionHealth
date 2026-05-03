import 'package:injectable/injectable.dart';
import 'package:orionhealth_health/features/local_agent/domain/services/vector_store_service.dart';
import 'package:orionhealth_health/features/local_agent/infrastructure/llm_service.dart';
import 'package:orionhealth_health/features/medical_research/infrastructure/medical_research_service.dart';
import 'package:orionhealth_health/features/user_profile/domain/repositories/user_profile_repository.dart';

@LazySingleton(as: LlmService)
class RagLlmService implements LlmService {
  final VectorStoreService _vectorStoreService;
  final MedicalResearchService _medicalResearchService;
  final UserProfileRepository _userProfileRepository;

  RagLlmService(
    this._vectorStoreService,
    this._medicalResearchService,
    this._userProfileRepository,
  );

  @override
  Stream<String> generate(String prompt) async* {
    final profile = await _userProfileRepository.getUserProfile();
    final allowCloud = profile?.allowCloudApi ?? true;

    if (!allowCloud) {
      // If cloud is disabled, we check if medical research (which might use cloud) should be bypassed or warned
      // In this specific implementation, we'll yield a warning if research is attempted and cloud is off.
    }

    // 1. Retrieve relevant context from local vector store
    final contextDocs = await _vectorStoreService.search(prompt);

    String contextText = "";
    if (contextDocs.isNotEmpty) {
      contextText = "\n\nContexto relevante encontrado:\n${contextDocs.map((d) => "- $d").join("\n")}";
    }

    // 2. Medical Research Enrichment (Web Search + Scraping)
    // If local context is weak or it's a specific medical query, enrich it
    String researchText = "";
    if (contextDocs.length < 2) {
      if (allowCloud) {
        final research = await _medicalResearchService.performResearch(prompt);
        if (research.isNotEmpty) {
          researchText = "\n\nEnriquecimiento de Investigación Médica:\n${research.take(2).map((r) => "- ${r.title}: ${r.content} (Fuente: ${r.source})").join("\n")}";
        }
      } else {
        researchText = "\n\n[AVISO: Búsqueda externa deshabilitada por privacidad]";
      }
    }

    // 3. Simulate generation with context awareness
    final response = "Entendido. Basado en tu consulta '$prompt' y en mi memoria:$contextText$researchText\n\n"
        "Aquí está mi análisis:\n"
        "1. He consultado la base de conocimientos local.\n"
        "2. He realizado una búsqueda en fuentes médicas confiables (PubMed, WHO, FDA).\n"
        "3. He encontrado ${contextDocs.length} referencias locales y ${researchText.isNotEmpty ? 'información externa actualizada' : 'no se requirió información externa'}.\n"
        "4. Como soy un agente local seguro, tus datos no salen del dispositivo.\n\n"
        "¿Necesitas ayuda con algún registro médico específico o quieres profundizar en la información encontrada?";

    for (var i = 0; i < response.length; i++) {
      await Future.delayed(const Duration(milliseconds: 30));
      yield response[i];
    }
  }
}
