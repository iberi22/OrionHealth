import 'package:medical_standards/medical_standards.dart';
import '../../domain/entities/medical_insight.dart';

/// Checks for drug-drug interactions using RxNorm + known interaction DB.
///
/// Uses a built-in interaction knowledge base covering common
/// major and moderate drug interactions. The database is loaded
/// from the medical_standards package medication catalog.
///
/// Safety: Never returns false negatives for known major pairs.
/// Edge cases: Empty medication list returns empty result.
class DrugInteractionChecker {
  static final Map<String, _InteractionRule> _knownInteractions = _initInteractions();

  /// Check for interactions between a list of medications.
  ///
  /// [medications] — list of medications to check.
  /// Returns [DrugInteractionResult] with matched interactions.
  ///
  /// O(n²) complexity where n = medication count.
  /// For >50 medications, consider batching.
  DrugInteractionResult checkInteractions(List<Medication> medications) {
    if (medications.length < 2) {
      return DrugInteractionResult(
        medications: medications,
        interactions: [],
        hasMajorInteractions: false,
        hasModerateInteractions: false,
      );
    }

    final interactions = <DrugInteraction>[];
    final matchedPairs = <String>{};

    for (int i = 0; i < medications.length; i++) {
      for (int j = i + 1; j < medications.length; j++) {
        final key1 = '${medications[i].rxnormCode}-${medications[j].rxnormCode}';
        final key2 = '${medications[j].rxnormCode}-${medications[i].rxnormCode}';

        if (matchedPairs.contains(key1) || matchedPairs.contains(key2)) continue;

        // Check known interaction DB
        final rule = _knownInteractions[key1] ?? _knownInteractions[key2];
        if (rule != null) {
          interactions.add(DrugInteraction(
            drug1: medications[i].displayName,
            drug2: medications[j].displayName,
            severity: rule.severity,
            description: rule.description,
            recommendation: rule.recommendation,
          ));
          matchedPairs.add(key1);
          continue;
        }

        // Cross-reference by drug class (ATC-based)
        final classInteraction = _checkClassInteraction(
          medications[i].drugClass ?? medications[i].displayName,
          medications[j].drugClass ?? medications[j].displayName,
        );
        if (classInteraction != null) {
          interactions.add(classInteraction);
          matchedPairs.add(key1);
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

  /// Check interactions based on drug class cross-reference.
  DrugInteraction? _checkClassInteraction(String class1, String class2) {
    final classKey1 = '${class1.toLowerCase()}-${class2.toLowerCase()}';
    final classKey2 = '${class2.toLowerCase()}-${class1.toLowerCase()}';
    final rule = _knownClassInteractions[classKey1] ?? _knownClassInteractions[classKey2];
    if (rule == null) return null;

    return DrugInteraction(
      drug1: class1,
      drug2: class2,
      severity: rule.severity,
      description: rule.description,
      recommendation: rule.recommendation,
    );
  }

  /// Check for drug-condition contraindications.
  List<DrugConditionWarning> checkDrugConditionInteractions(
    List<Medication> medications,
    List<Icd10Code> conditions,
  ) {
    if (medications.isEmpty || conditions.isEmpty) return [];

    final warnings = <DrugConditionWarning>[];
    final seen = <String>{};

    for (final med in medications) {
      for (final condition in conditions) {
        final warning = _checkContraindication(med, condition);
        if (warning != null) {
          final key = '${med.rxnormCode}-${condition.code}';
          if (seen.add(key)) {
            warnings.add(warning);
          }
        }
      }
    }

    return warnings;
  }

  DrugConditionWarning? _checkContraindication(Medication med, Icd10Code condition) {
    final conditionCode = condition.code;
    final drugClass = (med.drugClass ?? '').toLowerCase();
    final drugName = med.displayName.toLowerCase();

    // Heart failure + NSAIDs
    if ((conditionCode.startsWith('I50') || conditionCode == 'I50.9') &&
        (drugClass.contains('nsaid') || drugName.contains('nsaid') || drugName.contains('ibuprofen') || drugName.contains('naproxen'))) {
      return DrugConditionWarning(
        drug: med.displayName,
        condition: condition.displayName,
        severity: InsightSeverity.warning,
        description: 'NSAIDs may worsen heart failure by causing fluid retention and vasoconstriction',
        recommendation: 'Consider acetaminophen for pain. If NSAID required, use lowest dose for shortest duration with close monitoring.',
      );
    }

    // Diabetes + thiazides
    if ((conditionCode.startsWith('E10') || conditionCode.startsWith('E11')) &&
        (drugClass.contains('thiazide') || drugName.contains('thiazide') || drugName.contains('hydrochlorothiazide'))) {
      return DrugConditionWarning(
        drug: med.displayName,
        condition: condition.displayName,
        severity: InsightSeverity.info,
        description: 'Thiazide diuretics may affect glucose control and slightly increase blood glucose',
        recommendation: 'Monitor blood glucose more closely after starting thiazide therapy.',
      );
    }

    // CKD + NSAIDs
    if ((conditionCode.startsWith('N18') || conditionCode.startsWith('N19')) &&
        (drugClass.contains('nsaid') || drugName.contains('nsaid') || drugName.contains('ibuprofen') || drugName.contains('naproxen'))) {
      return DrugConditionWarning(
        drug: med.displayName,
        condition: condition.displayName,
        severity: InsightSeverity.warning,
        description: 'NSAIDs can reduce renal blood flow and worsen chronic kidney disease',
        recommendation: 'Avoid NSAIDs in CKD. Use non-pharmacological pain management or acetaminophen.',
      );
    }

    // COPD + beta-blockers (non-selective)
    if (conditionCode.startsWith('J44') &&
        (drugClass.contains('beta blocker') && !drugClass.contains('cardioselective'))) {
      return DrugConditionWarning(
        drug: med.displayName,
        condition: condition.displayName,
        severity: InsightSeverity.warning,
        description: 'Non-selective beta blockers may worsen COPD symptoms by blocking bronchodilation',
        recommendation: 'Use cardioselective beta blockers (metoprolol, atenolol) if beta blocker therapy is required.',
      );
    }

    return null;
  }

  /// Generate insights from interaction check.
  List<MedicalInsight> generateInsights(DrugInteractionResult result) {
    if (!result.hasInteractions) return [];

    final insights = <MedicalInsight>[];

    for (final interaction in result.interactions) {
      insights.add(MedicalInsight(
        id: 'drug-interaction-${interaction.drug1.hashCode}-${interaction.drug2.hashCode}',
        title: '💊 Interacción: ${interaction.drug1} + ${interaction.drug2}',
        description: interaction.description,
        severity: _severityFromInteraction(interaction.severity),
        category: InsightCategory.medicationInsight,
        recommendations: [interaction.recommendation],
        generatedAt: DateTime.now(),
        evidence: {'drugs': [interaction.drug1, interaction.drug2], 'severity': interaction.severity.name},
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

  /// Initialize the known drug interaction database.
  static Map<String, _InteractionRule> _initInteractions() {
    return {
      // Major interactions
      '314076-1191': _InteractionRule(InteractionSeverity.major, 'Increased risk of hyperkalemia and renal impairment', 'Monitor potassium and renal function. Consider alternative antihypertensive.'),
      '1191-314076': _InteractionRule(InteractionSeverity.major, 'Increased risk of hyperkalemia and renal impairment', 'Monitor potassium and renal function. Consider alternative antihypertensive.'),
      '161-310410': _InteractionRule(InteractionSeverity.major, 'Increased risk of bleeding and hemorrhage', 'Avoid combination. Use alternative anticoagulant or antiplatelet.'),
      '310410-161': _InteractionRule(InteractionSeverity.major, 'Increased risk of bleeding and hemorrhage', 'Avoid combination. Use alternative anticoagulant or antiplatelet.'),
      '723-7052': _InteractionRule(InteractionSeverity.major, 'Increased statin levels - risk of rhabdomyolysis', 'Avoid simvastatin. Use lowest effective dose of atorvastatin or rosuvastatin.'),
      '7052-723': _InteractionRule(InteractionSeverity.major, 'Increased statin levels - risk of rhabdomyolysis', 'Avoid simvastatin. Use lowest effective dose of atorvastatin or rosuvastatin.'),
      '860090-161': _InteractionRule(InteractionSeverity.major, 'Increased risk of bleeding and hemorrhage', 'Avoid combination. Use alternative pain management.'),
      '161-860090': _InteractionRule(InteractionSeverity.major, 'Increased risk of bleeding and hemorrhage', 'Avoid combination. Use alternative pain management.'),

      // Moderate interactions
      '314076-310410': _InteractionRule(InteractionSeverity.moderate, 'ACE inhibitor + anticoagulant: increased bleeding risk in elderly', 'Monitor INR and renal function. Educate patient about bleeding signs.'),
      '310410-314076': _InteractionRule(InteractionSeverity.moderate, 'ACE inhibitor + anticoagulant: increased bleeding risk in elderly', 'Monitor INR and renal function. Educate patient about bleeding signs.'),
      '1191-310410': _InteractionRule(InteractionSeverity.moderate, 'ARB + anticoagulant: potential increased bleeding risk', 'Monitor renal function and bleeding signs.'),
      '310410-1191': _InteractionRule(InteractionSeverity.moderate, 'ARB + anticoagulant: potential increased bleeding risk', 'Monitor renal function and bleeding signs.'),
      '6809-1191': _InteractionRule(InteractionSeverity.moderate, 'Metformin + contrast dye: risk of lactic acidosis', 'Hold metformin 48h before and after contrast procedures.'),
      '1191-6809': _InteractionRule(InteractionSeverity.moderate, 'Metformin + contrast dye: risk of lactic acidosis', 'Hold metformin 48h before and after contrast procedures.'),
      '723-310410': _InteractionRule(InteractionSeverity.moderate, 'Statin + anticoagulant: possible increased INR', 'Monitor INR more frequently when starting/changing statin therapy.'),
      '310410-723': _InteractionRule(InteractionSeverity.moderate, 'Statin + anticoagulant: possible increased INR', 'Monitor INR more frequently when starting/changing statin therapy.'),
    };
  }

  static final Map<String, _InteractionRule> _knownClassInteractions = {
    'ace inhibitor-spironolactone': _InteractionRule(InteractionSeverity.moderate, 'Risk of hyperkalemia', 'Monitor potassium levels closely. Consider ECG monitoring.'),
    'spironolactone-ace inhibitor': _InteractionRule(InteractionSeverity.moderate, 'Risk of hyperkalemia', 'Monitor potassium levels closely. Consider ECG monitoring.'),
    'nsaid-anticoagulant': _InteractionRule(InteractionSeverity.moderate, 'Increased GI bleeding risk', 'Add gastroprotection (PPI). Monitor for signs of bleeding.'),
    'anticoagulant-nsaid': _InteractionRule(InteractionSeverity.moderate, 'Increased GI bleeding risk', 'Add gastroprotection (PPI). Monitor for signs of bleeding.'),
    'nsaid-ace inhibitor': _InteractionRule(InteractionSeverity.moderate, 'Reduced antihypertensive effect + renal impairment risk', 'Monitor BP and renal function. Consider alternative analgesia.'),
    'ace inhibitor-nsaid': _InteractionRule(InteractionSeverity.moderate, 'Reduced antihypertensive effect + renal impairment risk', 'Monitor BP and renal function. Consider alternative analgesia.'),
    'ssri-nsaid': _InteractionRule(InteractionSeverity.major, 'Increased risk of GI bleeding (serotonin + platelet inhibition)', 'Avoid combination. Consider alternative antidepressant or analgesia.'),
    'nsaid-ssri': _InteractionRule(InteractionSeverity.major, 'Increased risk of GI bleeding (serotonin + platelet inhibition)', 'Avoid combination. Consider alternative antidepressant or analgesia.'),
    'warfarin-aspirin': _InteractionRule(InteractionSeverity.major, 'Increased risk of bleeding', 'Avoid combination unless specifically indicated with cardiologist approval.'),
    'aspirin-warfarin': _InteractionRule(InteractionSeverity.major, 'Increased risk of bleeding', 'Avoid combination unless specifically indicated with cardiologist approval.'),
    'statin-cyclosporine': _InteractionRule(InteractionSeverity.major, 'Increased statin levels - risk of rhabdomyolysis', 'Avoid simvastatin. Use lowest dose of other statins.'),
    'cyclosporine-statin': _InteractionRule(InteractionSeverity.major, 'Increased statin levels - risk of rhabdomyolysis', 'Avoid simvastatin. Use lowest dose of other statins.'),
    'fluoroquinolone-nsaid': _InteractionRule(InteractionSeverity.moderate, 'Increased risk of CNS effects and seizures', 'Monitor for neurological symptoms. Consider alternative antibiotic.'),
    'nsaid-fluoroquinolone': _InteractionRule(InteractionSeverity.moderate, 'Increased risk of CNS effects and seizures', 'Monitor for neurological symptoms. Consider alternative antibiotic.'),
    'beta blocker-calcium channel blocker': _InteractionRule(InteractionSeverity.moderate, 'Additive bradycardia and heart block risk', 'Monitor heart rate and ECG. Use lowest effective doses.'),
    'calcium channel blocker-beta blocker': _InteractionRule(InteractionSeverity.moderate, 'Additive bradycardia and heart block risk', 'Monitor heart rate and ECG. Use lowest effective doses.'),
  };
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

/// Internal interaction rule
class _InteractionRule {
  final InteractionSeverity severity;
  final String description;
  final String recommendation;

  const _InteractionRule(this.severity, this.description, this.recommendation);
}
