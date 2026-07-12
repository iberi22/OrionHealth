import 'package:flutter/material.dart';
import 'package:research_package/research_package.dart';
import '../domain/models/health_survey.dart';
import '../data/assessment_repository.dart';

class SurveyScreen extends StatelessWidget {
  final AssessmentRepository repository;

  const SurveyScreen({Key? key, required this.repository}) : super(key: key);

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
