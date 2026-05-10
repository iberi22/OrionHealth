import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/core/services/privacy_anonymizer.dart';
import 'package:orionhealth_health/features/local_agent/domain/services/llm_adapter.dart';
import 'package:orionhealth_health/features/local_agent/domain/services/vector_store_service.dart';
import 'package:orionhealth_health/features/reports/domain/entities/report.dart';
import 'package:orionhealth_health/features/reports/infrastructure/services/gemma_report_generation_service.dart';
import 'package:orionhealth_health/features/user_profile/domain/repositories/user_profile_repository.dart';

class MockLlmAdapter extends Mock implements LlmAdapter {}
class MockVectorStoreService extends Mock implements VectorStoreService {}
class MockUserProfileRepository extends Mock implements UserProfileRepository {}
class MockPromptScrubber extends Mock implements PromptScrubber {}

void main() {
  late GemmaReportGenerationService service;
  late MockLlmAdapter mockLlm;
  late MockVectorStoreService mockVectorStore;
  late MockUserProfileRepository mockProfileRepo;
  late MockPromptScrubber mockScrubber;

  setUp(() {
    mockLlm = MockLlmAdapter();
    mockVectorStore = MockVectorStoreService();
    mockProfileRepo = MockUserProfileRepository();
    mockScrubber = MockPromptScrubber();

    service = GemmaReportGenerationService(
      mockLlm,
      mockVectorStore,
      mockProfileRepo,
      mockScrubber,
    );

    // Default behaviors
    when(() => mockScrubber.scrub(any(), apiName: any(named: 'apiName')))
        .thenAnswer((invocation) async => invocation.positionalArguments[0] as String);
    when(() => mockVectorStore.search(any())).thenAnswer((_) async => []);
    when(() => mockProfileRepo.getUserProfile()).thenAnswer((_) async => null);
  });

  group('GemmaReportGenerationService', () {
    test('throws ArgumentError when prompt is empty', () async {
      expect(
        () => service.generateReport(prompt: '', contextData: []),
        throwsArgumentError,
      );
      expect(
        () => service.generateReport(prompt: '   ', contextData: []),
        throwsArgumentError,
      );
    });

    test('scrubs prompt before processing', () async {
      const originalPrompt = 'Mi correo es test@example.com';
      const scrubbedPrompt = 'Mi correo es [EMAIL]';

      when(() => mockScrubber.scrub(originalPrompt, apiName: any(named: 'apiName')))
          .thenAnswer((_) async => scrubbedPrompt);
      when(() => mockLlm.generate(any())).thenAnswer((_) async => '# Informe\nContenido');

      await service.generateReport(prompt: originalPrompt, contextData: []);

      verify(() => mockScrubber.scrub(originalPrompt, apiName: 'GemmaReportGenerationService')).called(1);
      verify(() => mockVectorStore.search(scrubbedPrompt)).called(1);
    });

    test('sets status to urgent when red flags are present', () async {
      when(() => mockLlm.generate(any())).thenAnswer((_) async => 'El paciente presenta taquicardia severa.');

      final report = await service.generateReport(prompt: 'Analiza mis síntomas', contextData: []);

      expect(report.status, ReportStatus.urgent);
    });

    test('sets status to urgent when red flags are in prompt', () async {
      when(() => mockLlm.generate(any())).thenAnswer((_) async => 'Reporte normal.');

      final report = await service.generateReport(prompt: 'Tengo un fuerte dolor torácico', contextData: []);

      expect(report.status, ReportStatus.urgent);
    });

    test('sets status to finalized for non-urgent reports', () async {
      when(() => mockLlm.generate(any())).thenAnswer((_) async => 'Todo parece estar bien.');

      final report = await service.generateReport(prompt: 'Chequeo de rutina', contextData: []);

      expect(report.status, ReportStatus.finalized);
    });

    test('extracts title from H1', () async {
      when(() => mockLlm.generate(any())).thenAnswer((_) async => '# Resumen de Salud Diaria\nContenido...');

      final report = await service.generateReport(prompt: 'Test', contextData: []);

      expect(report.title, 'Resumen de Salud Diaria');
    });

    test('uses fallback report when LLM fails', () async {
      when(() => mockLlm.generate(any())).thenThrow(Exception('LLM offline'));

      final report = await service.generateReport(prompt: 'Test', contextData: ['Dato 1']);

      expect(report.content, contains('# Informe de Salud'));
      expect(report.content, contains('Dato 1'));
      expect(report.content, contains('offline'));
    });
  });
}
