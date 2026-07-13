import 'package:flutter/material.dart';
import 'package:research_package/research_package.dart';
import '../domain/models/health_survey.dart';
import '../domain/repositories/i_assessment_repository.dart';

class SurveyScreen extends StatelessWidget {
  final IAssessmentRepository repository;

  const SurveyScreen({super.key, required this.repository});

  void _onTaskFinished(RPTaskResult result) {
    // Save to local database
    repository.saveAssessmentResult('health_survey', result);
  }

  void _onTaskCanceled(RPTaskResult? result) {
    // Handle cancel
  }

  @override
  Widget build(BuildContext context) {
    return RPUITask(
      task: LocalHealthSurvey.surveyTask,
      onSubmit: _onTaskFinished,
      onCancel: _onTaskCanceled,
    );
  }
}
