import 'package:flutter/material.dart';
import 'package:research_package/research_package.dart';
import '../domain/models/consent_document.dart';
import '../domain/repositories/i_assessment_repository.dart';

class ConsentScreen extends StatelessWidget {
  final IAssessmentRepository repository;

  const ConsentScreen({super.key, required this.repository});

  void _onConsentResult(RPTaskResult result) {
    // Save to local database
    repository.saveAssessmentResult('informed_consent', result);
  }

  void _onConsentCancel(RPTaskResult? result) {
    // Handle cancel
  }

  @override
  Widget build(BuildContext context) {
    return RPUITask(
      task: RPOrderedTask(
        identifier: "consent_task",
        steps: [
          RPConsentReviewStep(
            identifier: "consent_review",
            title: "Revisión de Consentimiento",
            consentDocument: LocalConsentDocument.consentDocument,
            reasonForConsent: "Consentimiento para procesar datos de salud localmente",
            text: "Por favor revisa el documento y firma si estás de acuerdo.",
          )
        ],
      ),
      onSubmit: _onConsentResult,
      onCancel: _onConsentCancel,
    );
  }
}
