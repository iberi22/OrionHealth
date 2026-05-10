import 'package:injectable/injectable.dart';
import '../../../../features/local_agent/domain/services/llm_adapter.dart';
import '../../../../core/services/privacy_anonymizer.dart';
import '../../../../features/local_agent/domain/services/vector_store_service.dart';
import '../../../../features/user_profile/domain/repositories/user_profile_repository.dart';
import '../../domain/entities/report.dart';
import '../../domain/services/report_generation_service.dart';

/// Real report generation using Gemma/Gemini LLM with RAG context.
///
/// Pipeline:
/// 1. Retrieve relevant medical context from local VectorStore (HiRAG)
/// 2. Load user profile for personalization
/// 3. Generate report via Gemma 4 local → Gemini cloud fallback
/// 4. Parse and structure the report content as Markdown
@LazySingleton(as: ReportGenerationService)
class GemmaReportGenerationService implements ReportGenerationService {
  final LlmAdapter _llmAdapter;
  final VectorStoreService _vectorStoreService;
  final UserProfileRepository _userProfileRepository;
  final PromptScrubber _promptScrubber;

  GemmaReportGenerationService(
    @Named('gemma') this._llmAdapter,
    this._vectorStoreService,
    this._userProfileRepository,
    this._promptScrubber,
  );

  @override
  Future<Report> generateReport({
    required String prompt,
    required List<String> contextData,
  }) async {
    if (prompt.trim().isEmpty) {
      throw ArgumentError('Prompt cannot be empty');
    }

    final scrubbedPrompt = await _promptScrubber.scrub(
      prompt,
      apiName: 'GemmaReportGenerationService',
    );

    final now = DateTime.now();

    // 1. Retrieve relevant medical knowledge from local vector store (HiRAG)
    final knowledgeDocs = await _vectorStoreService.search(scrubbedPrompt);
    final knowledgeContext = knowledgeDocs.isNotEmpty
        ? '\n## Conocimiento Médico Relevante\n${knowledgeDocs.map((d) => "- $d").join('\n')}'
        : '';

    // 2. Load user profile for personalized context
    String profileContext = '';
    try {
      final profile = await _userProfileRepository.getUserProfile();
      if (profile != null) {
        final conditions = profile.medicalConditions.isNotEmpty
            ? 'Condiciones: ${profile.medicalConditions.join(", ")}. '
            : '';
        final medications = profile.currentMedications.isNotEmpty
            ? 'Medicamentos: ${profile.currentMedications.join(", ")}. '
            : '';
        profileContext = '\n## Perfil del Paciente\n$conditions$medications';
      }
    } catch (_) {
      // Profile unavailable — continue without it
    }

    // 3. Build comprehensive system prompt for medical report generation
    final systemPrompt = '''
Eres OrionHealth, un asistente clínico de alto razonamiento. Genera un informe médico profesional y detallado.

DIRECTRICES:
1. Analiza los datos proporcionados y el contexto médico.
2. Estructura el informe en secciones claras con formato Markdown.
3. Incluye: Resumen, Análisis de Datos, Hallazgos Clave, Recomendaciones, y Notas de Seguridad.
4. Cita estándares médicos relevantes (ICD-10, LOINC) cuando aplique.
5. USA LENGUAJE PRECISO pero comprensible para el paciente.
6. NUNCA proporciones un diagnóstico definitivo. Usa lenguaje especulativo.
7. SIEMPRE incluye un disclaimer: "Este informe es generado por IA. Consulta a un profesional de la salud."

DATOS DEL PACIENTE:
${contextData.map((d) => "- $d").join('\n')}
$profileContext
$knowledgeContext

SOLICITUD DEL INFORME: $scrubbedPrompt
''';

    // 4. Generate report via LLM (Gemma local → Gemini cloud fallback)
    String reportContent;
    try {
      reportContent = await _llmAdapter.generate(systemPrompt);
    } catch (e) {
      // Graceful fallback with structured content
      reportContent = _buildFallbackReport(now, scrubbedPrompt, contextData, knowledgeDocs);
    }

    // 5. Determine report status based on content analysis
    final status = _determineStatus(reportContent, scrubbedPrompt);

    // 6. Extract title from content or generate one
    final title = _extractTitle(reportContent) ??
        'Informe de Salud — ${now.toString().split('.')[0]}';

    return Report(
      generatedAt: now,
      title: title,
      content: reportContent,
      status: status,
    );
  }

  /// Extract the first H1 heading as the report title.
  String? _extractTitle(String content) {
    final match = RegExp(r'^#\s+(.+)$', multiLine: true).firstMatch(content);
    return match?.group(1)?.trim();
  }

  /// Determine report status based on keywords in content and prompt.
  ReportStatus _determineStatus(String content, String prompt) {
    final combined = '${prompt.toLowerCase()} ${content.toLowerCase()}';

    final urgentKeywords = [
      'urgente', 'crítico', 'emergencia', 'grave', 'severa',
      'riesgo alto', 'atención inmediata', 'hospitalización',
      'taquicardia', 'síncope', 'hemorragia', 'dolor torácico', 'disnea',
    ];

    for (final keyword in urgentKeywords) {
      if (combined.contains(keyword)) {
        return ReportStatus.urgent;
      }
    }

    return ReportStatus.finalized;
  }

  /// Build a fallback structured report when LLM is unavailable.
  String _buildFallbackReport(
    DateTime now,
    String prompt,
    List<String> contextData,
    List<String> knowledgeDocs,
  ) {
    final buffer = StringBuffer();
    buffer.writeln('# Informe de Salud');
    buffer.writeln();
    buffer.writeln('**Fecha:** ${now.toIso8601String().split('T')[0]}');
    buffer.writeln('**Hora:** ${now.toIso8601String().split('T')[1].substring(0, 8)}');
    buffer.writeln();
    buffer.writeln('## Resumen');
    buffer.writeln('Informe generado basado en los datos clínicos proporcionados.');
    buffer.writeln();
    buffer.writeln('## Datos del Paciente');
    for (final d in contextData) {
      buffer.writeln('- $d');
    }
    buffer.writeln();
    if (knowledgeDocs.isNotEmpty) {
      buffer.writeln('## Referencias Médicas');
      for (final doc in knowledgeDocs) {
        buffer.writeln('- $doc');
      }
      buffer.writeln();
    }
    buffer.writeln('## Solicitud');
    buffer.writeln(prompt);
    buffer.writeln();
    buffer.writeln('---');
    buffer.writeln('*Nota: Este informe fue generado en modo offline.*');
    buffer.writeln('*Consulta a un profesional de la salud para una evaluación completa.*');

    return buffer.toString();
  }
}
