import 'package:isar/isar.dart';

part 'clinical_assessment_record.g.dart';

@collection
class ClinicalAssessmentRecord {
  Id id = Isar.autoIncrement;

  /// E.g., 'consent', 'survey_phq9', 'active_task_tremor'
  String? assessmentType;

  /// When it was completed
  DateTime? completedAt;

  /// The JSON representation of RPTaskResult
  String? resultJson;

  ClinicalAssessmentRecord({
    this.assessmentType,
    this.completedAt,
    this.resultJson,
  });
}
