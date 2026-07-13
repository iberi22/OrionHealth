// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:research_package/research_package.dart';
import '../entities/clinical_assessment_record.dart';

abstract class IAssessmentRepository {
  Future<void> saveAssessmentResult(String type, RPTaskResult result);
  Future<List<ClinicalAssessmentRecord>> getAllAssessments();
}
