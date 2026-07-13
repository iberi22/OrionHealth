import 'dart:convert';
import 'package:isar/isar.dart';
import 'package:research_package/research_package.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/clinical_assessment_record.dart';
import '../../domain/repositories/i_assessment_repository.dart';

@LazySingleton(as: IAssessmentRepository)
class AssessmentRepositoryImpl implements IAssessmentRepository {
  final Isar isar;

  AssessmentRepositoryImpl(this.isar);

  @override
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

  @override
  Future<List<ClinicalAssessmentRecord>> loadAssessments() async {
    return await isar.clinicalAssessmentRecords.where().findAll();
  }
}
