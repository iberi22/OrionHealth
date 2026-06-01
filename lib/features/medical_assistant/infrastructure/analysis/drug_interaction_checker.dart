import 'package:medical_standards/medical_standards.dart';
import '../../domain/entities/medical_insight.dart';

/// Checks for drug-drug interactions and medication-related insights
class DrugInteractionChecker {
  /// Check for interactions between a list of medications
  DrugInteractionResult checkInteractions(List<Medication> medications) {
    final interactions = <DrugInteraction>[];

    for (int i = 0; i < medications.length; i++) {
      for (int j = i + 1; j < medications.length; j++) {
        final interaction = _findInteraction(medications[i], medications[j]);
        if (interaction != null) {
          interactions.add(interaction);
        }
      }
    }

    return DrugInteractionResult(
      medications: medications,
      interactions: interactions,
      hasMajorInteractions: interactions.any((i) => i.severity == InteractionSeverity.major),
      hasModerateInteractions: interactions.any((i) => i.severity == InteractionSeverity.moderate),
    );
  }

  DrugInteraction? _findInteraction(Medication med1, Medication med2) {
    // Stub implementation - would use a comprehensive drug database
    // Common known interactions
    final pairs = <String, DrugInteraction>{
      'warfarin-aspirin': DrugInteraction(
        drug1: 'Warfarin',
        drug2: 'Aspirin',
        severity: InteractionSeverity.major,
        description: 'Increased risk of bleeding',
        recommendation: 'Avoid combination unless specifically indicated. Monitor closely.',
      ),
      'metformin-contrast': DrugInteraction(
        drug1: 'Metformin',
        drug2: 'Iodinated Contrast',
        severity: InteractionSeverity.major,
        description: 'Risk of lactic acidosis and acute kidney injury',
        recommendation: 'Hold metformin 48h before/after contrast procedures.',
      ),
      'acei-spironolactone': DrugInteraction(
        drug1: 'ACE Inhibitor',
        drug2: 'Spironolactone',
        severity: InteractionSeverity.moderate,
        description: 'Risk of hyperkalemia',
        recommendation: 'Monitor potassium levels closely.',
      ),
      'statin-cyclosporine': DrugInteraction(
        drug1: 'Statin',
        drug2: 'Cyclosporine',
        severity: InteractionSeverity.major,
        description: 'Increased statin levels - risk of rhabdomyolysis',
        recommendation: 'Avoid simvastatin. Use lowest dose of other statins.',
      ),
      'nsaid-anticoagulant': DrugInteraction(
        drug1: 'NSAID',
        drug2: 'Anticoagulant',
        severity: InteractionSeverity.moderate,
        description: 'Increased GI bleeding risk',
        recommendation: 'Add gastroprotection (PPI). Monitor for bleeding.',
      ),
    };

    final key1 = '${med1.rxnormCode}-${med2.rxnormCode}';
    final key2 = '${med2.rxnormCode}-${med1.rxnormCode}';
    
    return pairs[key1] ?? pairs[key2];
  }

  /// Check for drug-condition contraindications
  List<DrugConditionWarning> checkDrugConditionInteractions(
    List<Medication> medications,
    List<Icd10Code> conditions,
  ) {
    final warnings = <DrugConditionWarning>[];

    for (final med in medications) {
      for (final condition in conditions) {
        final warning = _checkContraindication(med, condition);
        if (warning != null) {
          warnings.add(warning);
        }
      }
    }

    return warnings;
  }

  DrugConditionWarning? _checkContraindication(Medication med, Icd10Code condition) {
    // Stub - would use comprehensive database
    // Example contraindications
    if (condition.code == 'I50.9' && med.rxnormCode.contains('NSAID')) {
      return DrugConditionWarning(
        drug: med.displayName,
        condition: condition.displayName,
        severity: InsightSeverity.warning,
        description: 'NSAIDs may worsen heart failure',
        recommendation: 'Consider alternatives. Use lowest dose for shortest duration.',
      );
    }

    if (condition.code == 'E11' && med.rxnormCode.contains('thiazide')) {
      return DrugConditionWarning(
        drug: med.displayName,
        condition: condition.displayName,
        severity: InsightSeverity.info,
        description: 'Thiazides may affect glucose control',
        recommendation: 'Monitor blood glucose more closely.',
      );
    }

    return null;
  }

  /// Generate insights from interaction check
  List<MedicalInsight> generateInsights(DrugInteractionResult result) {
    final insights = <MedicalInsight>[];

    for (final interaction in result.interactions) {
      insights.add(MedicalInsight(
        id: 'drug-interaction-${interaction.drug1}-${interaction.drug2}',
        title: 'Drug Interaction: ${interaction.drug1} + ${interaction.drug2}',
        description: interaction.description,
        severity: _severityFromInteraction(interaction.severity),
        category: InsightCategory.medicationInsight,
        recommendations: [interaction.recommendation],
        generatedAt: DateTime.now(),
        evidence: {'drugs': [interaction.drug1, interaction.drug2]},
      ));
    }

    return insights;
  }

  InsightSeverity _severityFromInteraction(InteractionSeverity severity) {
    switch (severity) {
      case InteractionSeverity.major:
        return InsightSeverity.critical;
      case InteractionSeverity.moderate:
        return InsightSeverity.warning;
      case InteractionSeverity.minor:
        return InsightSeverity.info;
    }
  }
}

/// Drug-drug interaction
class DrugInteraction {
  final String drug1;
  final String drug2;
  final InteractionSeverity severity;
  final String description;
  final String recommendation;

  DrugInteraction({
    required this.drug1,
    required this.drug2,
    required this.severity,
    required this.description,
    required this.recommendation,
  });
}

/// Drug-condition warning
class DrugConditionWarning {
  final String drug;
  final String condition;
  final InsightSeverity severity;
  final String description;
  final String recommendation;

  DrugConditionWarning({
    required this.drug,
    required this.condition,
    required this.severity,
    required this.description,
    required this.recommendation,
  });
}

/// Drug interaction check result
class DrugInteractionResult {
  final List<Medication> medications;
  final List<DrugInteraction> interactions;
  final bool hasMajorInteractions;
  final bool hasModerateInteractions;

  DrugInteractionResult({
    required this.medications,
    required this.interactions,
    required this.hasMajorInteractions,
    required this.hasModerateInteractions,
  });

  bool get hasInteractions => interactions.isNotEmpty;
  int get totalInteractions => interactions.length;
}

/// Interaction severity levels
enum InteractionSeverity { major, moderate, minor }
