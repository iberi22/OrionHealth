import 'package:injectable/injectable.dart';
import '../../domain/entities/health_report.dart';
import '../../domain/services/report_generation_service.dart';

@LazySingleton(as: ReportGenerationService)
class MockReportGenerationService implements ReportGenerationService {
  @override
  Future<HealthReport> generateReport({
    required String prompt,
    required List<String> contextData,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    final mockContent = '''
# Informe de Salud Generado

**Fecha:** ${DateTime.now().toIso8601String()}

## Resumen
Este es un informe generado automáticamente basado en los datos proporcionados.

## Análisis
Basado en los registros médicos recientes:
${contextData.map((e) => "- $e").join('\n')}

## Recomendaciones
1. Mantener una dieta equilibrada.
2. Realizar ejercicio regularmente.
3. Consultar a un especialista si los síntomas persisten.

*Nota: Este informe es generado por una IA y no sustituye el consejo médico profesional.*
''';

    return HealthReport(
      generatedAt: DateTime.now(),
      title: 'Informe de Salud - ${DateTime.now().toString().split(' ')[0]}',
      content: mockContent,
    );
  }
}
