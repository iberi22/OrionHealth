import 'package:research_package/research_package.dart';
import '../entities/clinical_assessment_record.dart';

abstract class IAssessmentRepository {
  Future<void> saveAssessmentResult(String type, RPTaskResult result);
  Future<List<ClinicalAssessmentRecord>> loadAssessments();
}
