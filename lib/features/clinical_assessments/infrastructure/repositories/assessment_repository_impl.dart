<<<<<<<< HEAD:lib/features/clinical_assessments/data/assessment_repository.dart
// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:isar/isar.dart';
import '../infrastructure/repositories/assessment_repository_impl.dart';
import '../infrastructure/datasources/assessment_local_datasource.dart';

/// Export infrastructure implementation and domain interface for backward compatibility.
export '../domain/repositories/i_assessment_repository.dart';
export '../infrastructure/repositories/assessment_repository_impl.dart';
export '../infrastructure/datasources/assessment_local_datasource.dart';

/// Legacy AssessmentRepository that delegates to the new infrastructure implementation.
/// @deprecated Use IAssessmentRepository via dependency injection instead.
class AssessmentRepository extends AssessmentRepositoryImpl {
  AssessmentRepository(Isar isar) : super(AssessmentLocalDataSource(isar));
========
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
>>>>>>>> pr-1524:lib/features/clinical_assessments/infrastructure/repositories/assessment_repository_impl.dart
}
