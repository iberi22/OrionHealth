import '../../../local_agent/domain/entities/medical_code.dart';

/// Represents a diagnostic match with its relevance.
class DiagnosticMatch {
  final MedicalCode code;
  final double score;
  final String reasoning;

  DiagnosticMatch({
    required this.code,
    required this.score,
    required this.reasoning,
  });
}

/// Domain interface for advanced clinical reasoning.
abstract class ClinicalReasonerService {
  /// Analyzes symptoms and returns potential diagnoses with scores.
  Future<List<DiagnosticMatch>> analyzeSymptoms(String text);

  /// Analyzes a list of medications and returns potential interactions.
  Future<List<Map<String, dynamic>>> analyzeMedications(List<String> drugNamesOrCodes);

  /// Synthesizes a holistic summary (physical + mental) for a set of codes.
  String synthesizeHolisticSummary(List<MedicalCode> codes);
}
