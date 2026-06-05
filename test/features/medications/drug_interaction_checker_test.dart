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
    test('detects major interaction (Warfarin + Aspirin)', () {
      final medications = <Medication>[
        const Medication(code: '855332', displayName: 'Warfarin', drugClass: 'Anticoagulant'),
        const Medication(code: '1191', displayName: 'Aspirin', drugClass: 'NSAID/Antiplatelet'),
      ];

      final result = checker.checkInteractions(medications);

      expect(result.hasInteractions, true);
      expect(result.hasMajorInteractions, true);
      expect(result.interactions.first.severity, InteractionSeverity.major);
    });

    test('detects moderate interaction (NSAID + Anticoagulant)', () {
      final medications = <Medication>[
        const Medication(code: '5640', displayName: 'NSAID', drugClass: 'NSAID'),
        const Medication(code: '855332', displayName: 'Anticoagulant', drugClass: 'Anticoagulant'),
      ];

      final result = checker.checkInteractions(medications);
      expect(result.hasInteractions, true);
      expect(result.hasModerateInteractions, true);
    });

    test('safe combination (Acetaminophen + Amoxicillin) has no interactions', () {
      final medications = <Medication>[
        const Medication(code: '161', displayName: 'Acetaminophen'),
        const Medication(code: '723', displayName: 'Amoxicillin'),
      ];

      final result = checker.checkInteractions(medications);
      expect(result.hasInteractions, false);
    });

    test('handles empty list', () {
      final result = checker.checkInteractions([]);
      expect(result.hasInteractions, false);
      expect(result.medications, isEmpty);
    });

    test('handles unknown medications', () {
      final medications = <Medication>[
        const Medication(code: '999999', displayName: 'Unknown Drug A'),
        const Medication(code: '888888', displayName: 'Unknown Drug B'),
      ];

      final result = checker.checkInteractions(medications);
      expect(result.hasInteractions, false);
    });

    test('generates critical insights for major interactions', () {
      final medications = <Medication>[
        const Medication(code: '855332', displayName: 'Warfarin', drugClass: 'Anticoagulant'),
        const Medication(code: '1191', displayName: 'Aspirin', drugClass: 'NSAID/Antiplatelet'),
      ];

      final result = checker.checkInteractions(medications);
      final insights = checker.generateInsights(result);
      expect(insights.any((i) => i.severity == InsightSeverity.critical), true);
    });
  });

  group('DrugInteractionChecker - Drug-Condition Interactions', () {
    test('detects NSAID + Heart Failure when displayName contains "nsaid"', () {
      final medications = <Medication>[
        const Medication(code: '9999', displayName: 'Topical NSAID gel'),
      ];
      final conditions = [
        Icd10Code(code: 'I50.9', displayName: 'Heart Failure', category: 'Heart'),
      ];

      final warnings = checker.checkDrugConditionInteractions(medications, conditions);
      expect(warnings, hasLength(1));
      expect(warnings.first.severity, InsightSeverity.warning);
      expect(warnings.first.description, contains('heart failure'));
    });

    test('no warning when condition does not match criteria', () {
      final medications = <Medication>[
        const Medication(code: '5640', displayName: 'Ibuprofen'),
      ];
      final conditions = [
        Icd10Code(code: 'Z33.1', displayName: 'Pregnancy', category: 'Pregnancy'),
      ];

      final warnings = checker.checkDrugConditionInteractions(medications, conditions);
      expect(warnings, isEmpty);
    });

    test('detects thiazide + Diabetes interaction', () {
      final medications = <Medication>[
        const Medication(code: '123', displayName: 'Hydrochlorothiazide', drugClass: 'Thiazide'),
      ];
      final conditions = [
        Icd10Code(code: 'E11', displayName: 'Type 2 Diabetes', category: 'Endocrine'),
      ];

      final warnings = checker.checkDrugConditionInteractions(medications, conditions);
      expect(warnings, hasLength(1));
      expect(warnings.first.severity, InsightSeverity.info);
      expect(warnings.first.description, contains('glucose'));
    });
  });
}
