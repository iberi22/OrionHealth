import 'package:isar/isar.dart';
import 'dart:convert';
import 'package:research_package/research_package.dart';
import '../domain/entities/clinical_assessment_record.dart';

class AssessmentRepository {
  final Isar isar;

  AssessmentRepository(this.isar);

  Future<void> saveAssessmentResult(String type, RPTaskResult result) async {
    final resultJson = jsonEncode(result.toJson());
    
    final record = ClinicalAssessmentRecord(
      assessmentType: type,
      completedAt: DateTime.now(),
      resultJson: resultJson,
    );

    await isar.writeTxn(() async {
      await isar.clinicalAssessmentRecords.put(record);
    });
  }
}
