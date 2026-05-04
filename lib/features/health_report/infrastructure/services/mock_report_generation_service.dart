import 'package:injectable/injectable.dart';
import '../../../local_agent/domain/services/llm_adapter.dart';
import '../../domain/entities/health_report.dart';
import '../../domain/services/report_generation_service.dart';

@LazySingleton(as: ReportGenerationService)
class RealReportGenerationService implements ReportGenerationService {
  final LlmAdapter _llmAdapter;

  RealReportGenerationService(@Named('gemma') this._llmAdapter);

  @override
  Future<HealthReport> generateReport({
    required String prompt,
    required List<String> contextData,
  }) async {
    final generatedAt = DateTime.now();
    final reportPrompt = _buildReportPrompt(
      prompt: prompt,
      contextData: contextData,
      generatedAt: generatedAt,
    );

    final isAvailable = await _llmAdapter.isAvailable();
    if (!isAvailable) {
      throw StateError(
        'No local Gemma/Gemini LLM is available to generate reports.',
      );
    }

    final content = (await _llmAdapter.generate(reportPrompt)).trim();
    if (content.isEmpty) {
      throw StateError('The LLM returned an empty health report.');
    }

    return HealthReport(
      generatedAt: generatedAt,
      title:
          _extractTitle(content) ??
          'Informe de Salud - ${generatedAt.toString().split(' ')[0]}',
      content: content,
    );
  }

  String _buildReportPrompt({
    required String prompt,
    required List<String> contextData,
    required DateTime generatedAt,
  }) {
    final context =
        contextData.isEmpty
            ? 'No hay datos clinicos estructurados disponibles.'
            : contextData.map((item) => '- $item').join('\n');

    return '''
Eres el asistente local de OrionHealth para redactar reportes de salud.
Genera un informe medico en Markdown, en espanol claro y prudente.

Reglas:
- Usa solo los datos entregados en el contexto.
- No inventes diagnosticos, valores, medicamentos ni fechas.
- Diferencia hechos observados, posibles patrones y datos faltantes.
- Incluye una nota de que no sustituye criterio medico profesional.
- No incluyas texto fuera del Markdown del reporte.

Solicitud del usuario:
$prompt

Fecha de generacion:
${generatedAt.toIso8601String()}

Contexto clinico disponible:
$context

Estructura esperada:
# Titulo breve del informe
## Resumen
## Hallazgos relevantes
## Tendencias o alertas a vigilar
## Preguntas para el profesional de salud
## Nota
''';
  }

  String? _extractTitle(String content) {
    for (final line in content.split('\n')) {
      final trimmed = line.trim();
      if (trimmed.startsWith('# ')) {
        final title = trimmed.substring(2).trim();
        return title.isEmpty ? null : title;
      }
    }
    return null;
  }
}
