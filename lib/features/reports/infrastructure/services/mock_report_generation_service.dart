import 'package:injectable/injectable.dart';
import '../../domain/entities/report.dart';
import '../../domain/services/report_generation_service.dart';
import 'dart:math';

@LazySingleton(as: ReportGenerationService)
class MockReportGenerationService implements ReportGenerationService {
  @override
  Future<Report> generateReport({
    required String prompt,
    required List<String> contextData,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    final now = DateTime.now();
    final mockContent = '''
# Informe de Salud Generado

**Fecha:** ${now.toIso8601String()}

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

    // Random status for variety in mock data
    final statuses = ReportStatus.values;
    final randomStatus = statuses[Random().nextInt(statuses.length)];

    return Report(
      generatedAt: now,
      title: 'Informe de Salud - ${now.toString().split(' ')[0]}',
      content: mockContent,
      status: randomStatus,
    );
  }
}
