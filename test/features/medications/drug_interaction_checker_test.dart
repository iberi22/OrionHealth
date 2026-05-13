import 'package:flutter_test/flutter_test.dart';
import 'package:medical_standards/medical_standards.dart';
import 'package:orionhealth_health/features/medical_assistant/domain/entities/medical_insight.dart';
import 'package:orionhealth_health/features/medical_assistant/infrastructure/analysis/drug_interaction_checker.dart';

void main() {
  late DrugInteractionChecker checker;

  setUp(() {
    checker = DrugInteractionChecker();
  });

  group('DrugInteractionChecker - Drug-Drug Interactions', () {
    test('detects major interaction between specific RxNorm codes (Warfarin + Aspirin)', () {
      final medications = [
        const Medication(rxnormCode: '11289', displayName: 'Warfarin'),
        const Medication(rxnormCode: '1191', displayName: 'Aspirin'),
      ];

      final result = checker.checkInteractions(medications);

      expect(result.hasInteractions, true);
      expect(result.hasMajorInteractions, true);
      expect(result.interactions.first.severity, InteractionSeverity.major);
    });

    test('detects moderate interaction between drug classes (Ibuprofen + Lisinopril)', () {
      final medications = [
        const Medication(
          rxnormCode: '5640',
          displayName: 'Ibuprofen',
          drugClass: 'NSAID',
        ),
        const Medication(
          rxnormCode: '29046',
          displayName: 'Lisinopril',
          drugClass: 'ACE Inhibitor',
        ),
      ];

      final result = checker.checkInteractions(medications);

      expect(result.hasInteractions, true);
      expect(result.hasModerateInteractions, true);
      expect(result.interactions.any((i) => i.severity == InteractionSeverity.moderate), true);
    });

    test('returns no interactions for safe combination (Acetaminophen + Amoxicillin)', () {
      final medications = [
        const Medication(rxnormCode: '161', displayName: 'Acetaminophen'),
        const Medication(rxnormCode: '723', displayName: 'Amoxicillin'),
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
      final medications = [
        const Medication(rxnormCode: '999999', displayName: 'Unknown Drug A'),
        const Medication(rxnormCode: '888888', displayName: 'Unknown Drug B'),
      ];

      final result = checker.checkInteractions(medications);
      expect(result.hasInteractions, false);
    });

    test('generates critical insights for major interactions', () {
      final medications = [
        const Medication(rxnormCode: '11289', displayName: 'Warfarin'),
        const Medication(rxnormCode: '1191', displayName: 'Aspirin'),
      ];

      final result = checker.checkInteractions(medications);
      final insights = checker.generateInsights(result);

      expect(insights.any((i) => i.severity == InsightSeverity.critical), true);
    });

    test('supports Spanish medication names via displayName', () {
      final medications = [
        const Medication(
          rxnormCode: '11289',
          displayName: 'Warfarina',
          drugClass: 'anticoagulant'
        ),
        const Medication(
          rxnormCode: '5640',
          displayName: 'Aspirina',
          drugClass: 'nsaid'
        ),
      ];

      final result = checker.checkInteractions(medications);
      expect(result.hasInteractions, true);
    });
  });

  group('DrugInteractionChecker - Drug-Condition Interactions', () {
    test('detects NSAID + Heart Failure contraindication', () {
      final medications = [
        const Medication(rxnormCode: '5640', displayName: 'Ibuprofeno', drugClass: 'NSAID'),
      ];
      final conditions = [
        const Icd10Code(code: 'I50.9', displayName: 'Heart Failure', category: 'Heart'),
      ];

      final warnings = checker.checkDrugConditionInteractions(medications, conditions);

      expect(warnings, isNotEmpty);
      expect(warnings.first.severity, InsightSeverity.warning);
      expect(warnings.first.description, contains('heart failure'));
    });

    test('detects NSAID + CKD contraindication', () {
      final medications = [
        const Medication(rxnormCode: '5640', displayName: 'Ibuprofeno', drugClass: 'NSAID'),
      ];
      final conditions = [
        const Icd10Code(code: 'N18.9', displayName: 'Chronic Kidney Disease', category: 'Renal'),
      ];

      final warnings = checker.checkDrugConditionInteractions(medications, conditions);

      expect(warnings, isNotEmpty);
      expect(warnings.first.severity, InsightSeverity.warning);
      expect(warnings.first.description, contains('kidney disease'));
    });

    test('detects pregnancy contraindications', () {
      final medications = [
        const Medication(rxnormCode: '29046', displayName: 'Lisinopril', drugClass: 'ACE inhibitor'),
      ];
      final conditions = [
        const Icd10Code(code: 'Z33.1', displayName: 'Pregnancy', category: 'Pregnancy'),
      ];

      final warnings = checker.checkDrugConditionInteractions(medications, conditions);

      expect(warnings, isNotEmpty);
      expect(warnings.first.severity, InsightSeverity.critical);
      expect(warnings.first.condition, 'Pregnancy');
    });
  });
}
