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
}
