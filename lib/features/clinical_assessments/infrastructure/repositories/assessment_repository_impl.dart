// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'dart:convert';
import 'package:injectable/injectable.dart';
import 'package:research_package/research_package.dart';
import '../../domain/entities/clinical_assessment_record.dart';
import '../../domain/repositories/i_assessment_repository.dart';
import '../datasources/assessment_local_datasource.dart';

@LazySingleton(as: IAssessmentRepository)
class AssessmentRepositoryImpl implements IAssessmentRepository {
  final AssessmentLocalDataSource _localDataSource;

  AssessmentRepositoryImpl(this._localDataSource);

  @override
  Future<void> saveAssessmentResult(String type, RPTaskResult result) async {
    final resultJson = jsonEncode(result.toJson());

    final record = ClinicalAssessmentRecord(
      assessmentType: type,
      completedAt: DateTime.now(),
      resultJson: resultJson,
    );

    await _localDataSource.saveRecord(record);
  }

  @override
  Future<List<ClinicalAssessmentRecord>> getAllAssessments() async {
    return await _localDataSource.getAllRecords();
  }
}
