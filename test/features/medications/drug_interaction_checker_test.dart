import 'package:flutter_test/flutter_test.dart';
import 'package:medical_standards/medical_standards.dart';
import 'package:orionhealth_health/features/medical_assistant/domain/entities/medical_insight.dart';
import 'package:orionhealth_health/features/medical_assistant/infrastructure/analysis/drug_interaction_checker.dart';

void main() {
  late DrugInteractionChecker checker;

  setUp(() {
    checker = DrugInteractionChecker();
  });

  /// Helper to build a Medication from MedicationReference constants
  Medication _med(MedicationReference ref) {
    // The checker expects type `Medication` — which resolves to MedicationReference
    return ref as Medication;
  }

  group('DrugInteractionChecker - Drug-Drug Interactions', () {
    test('detects major interaction (Warfarin + Aspirin)', () {
      final medications = [
        MedicationCatalog.warfarin,
        MedicationCatalog.aspirin,
      ];

      final result = checker.checkInteractions(medications);

      expect(result.hasInteractions, true);
      expect(result.hasMajorInteractions, true);
      expect(result.interactions.first.severity, InteractionSeverity.major);
    });

    test('detects moderate interaction (NSAID + ACE Inhibitor)', () {
      final medications = [
        MedicationCatalog.ibuprofen,
        MedicationCatalog.lisinopril,
      ];

      final result = checker.checkInteractions(medications);

      expect(result.hasInteractions, true);
      expect(result.hasModerateInteractions, true);
      expect(result.interactions.any((i) => i.severity == InteractionSeverity.moderate), true);
    });

    test('returns no interactions for safe combination (Acetaminophen + Amoxicillin)', () {
      final medications = [
        MedicationCatalog.acetaminophen,
        MedicationCatalog.amoxicillin,
      ];

      final result = checker.checkInteractions(medications);
      expect(result.hasInteractions, false);
    });

    test('handles empty medication list gracefully', () {
      final result = checker.checkInteractions([]);
      expect(result.hasInteractions, false);
      expect(result.medications, isEmpty);
    });

    test('handles unknown medications gracefully', () {
      // Custom MedicationReference with unknown codes
      final meds = [
        const MedicationReference(code: '999999', displayName: 'Unknown Drug A'),
        const MedicationReference(code: '888888', displayName: 'Unknown Drug B'),
      ];

      final result = checker.checkInteractions(meds);
      expect(result.hasInteractions, false);
    });

    test('generates critical insights for major interactions', () {
      final medications = [
        MedicationCatalog.warfarin,
        MedicationCatalog.aspirin,
      ];

      final result = checker.checkInteractions(medications);
      final insights = checker.generateInsights(result);
      expect(insights.any((i) => i.severity == InsightSeverity.critical), true);
    });
  });

  group('DrugInteractionChecker - Drug-Condition Interactions', () {
    test('detects NSAID + Heart Failure contraindication', () {
      final medications = [MedicationCatalog.ibuprofen];
      final conditions = [
        Icd10Code(code: 'I50.9', displayName: 'Heart Failure', category: 'Heart'),
      ];

      final warnings = checker.checkDrugConditionInteractions(medications, conditions);
      expect(warnings, isNotEmpty);
      expect(warnings.first.severity, InsightSeverity.warning);
      expect(warnings.first.description, contains('heart failure'));
    });

    test('detects NSAID + CKD contraindication', () {
      final medications = [MedicationCatalog.ibuprofen];
      final conditions = [
        Icd10Code(code: 'N18.9', displayName: 'Chronic Kidney Disease', category: 'Renal'),
      ];

      final warnings = checker.checkDrugConditionInteractions(medications, conditions);
      expect(warnings, isNotEmpty);
      expect(warnings.first.severity, InsightSeverity.warning);
      expect(warnings.first.description, contains('kidney disease'));
    });

    test('detects pregnancy contraindications', () {
      final medications = [MedicationCatalog.lisinopril];
      final conditions = [
        Icd10Code(code: 'Z33.1', displayName: 'Pregnancy', category: 'Pregnancy'),
      ];

      final warnings = checker.checkDrugConditionInteractions(medications, conditions);
      expect(warnings, isNotEmpty);
      expect(warnings.first.severity, InsightSeverity.critical);
      expect(warnings.first.condition, 'Pregnancy');
    });
  });
}
