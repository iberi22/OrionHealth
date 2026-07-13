// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import '../../domain/entities/clinical_assessment_record.dart';

@lazySingleton
class AssessmentLocalDataSource {
  final Isar _isar;

  AssessmentLocalDataSource(this._isar);

  /// Saves a clinical assessment record to Isar.
  Future<void> saveRecord(ClinicalAssessmentRecord record) async {
    await _isar.writeTxn(() async {
      await _isar.clinicalAssessmentRecords.put(record);
    });
  }

  /// Returns all clinical assessment records from Isar.
  Future<List<ClinicalAssessmentRecord>> getAllRecords() async {
    return await _isar.clinicalAssessmentRecords.where().findAll();
  }
}
