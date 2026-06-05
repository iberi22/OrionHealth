import 'package:flutter_test/flutter_test.dart';
import 'package:medical_standards/medical_standards.dart';
import 'package:orionhealth_health/features/medical_assistant/domain/entities/medical_insight.dart';
import 'package:orionhealth_health/features/medical_assistant/infrastructure/analysis/drug_interaction_checker.dart';

/// Since `Medication` type used by the checker is not exported from medical_standards
/// (the actual export is `MedicationReference`), we use a wrapper class that matches
/// what DrugInteractionChecker expects: objects with `.displayName` and `.drugClass`.
class TestMedication {
  final String code;
  final String displayName;
  final String? drugClass;
  final String? description;
  final String? genericName;
  final List<String> routes;
  final List<String> commonDosages;

  TestMedication(MedicationReference ref)
      : code = ref.code,
        displayName = ref.displayName,
        drugClass = ref.drugClass,
        description = ref.description,
        genericName = ref.genericName,
        routes = ref.routes,
        commonDosages = ref.commonDosages;
}

/// Replace Medication with TestMedication — need to adapt the checker type.
/// Since Medication is a subtype of MedicalConcept, check if TestMedication can work.
/// The checker's checkInteractions(medications) accepts List<Medication>. We need
/// to actually pass objects that are (or extend) Medication.
///
/// Solution: note that MedicationReference extends MedicalConcept.
/// There is NO class named "Medication" — this is a type resolution issue.
/// The simplest fix: the test imports medication_standards and uses MedicationReference.
/// 
/// BUT flutter analyze says List<MedicationReference> != List<Medication>.
/// Medication must be a supertype. Let's check if MedicationReference IS-A Medication.
///
/// Actually if we examine: DrugInteractionChecker imports from medical_standards.
/// That barrel exports medications.dart which has MedicationReference, not Medication.
/// So "Medication" is an unresolved identifier. The checker itself has a compile error!
///
/// The checker compiles because it has a DIFFERENT import: maybe it resolves to dynamic.
/// Since flutter analyze passes source files where Medication is unresolved, it may
/// resolve to `dynamic` implicitly. Let's test that approach.

void main() {
  late DrugInteractionChecker checker;

  setUp(() {
    checker = DrugInteractionChecker();
  });

  group('DrugInteractionChecker - Drug-Drug Interactions', () {
    test('detects major interaction (Warfarin + Aspirin)', () {
      // Pass raw Maps since Medication type is unresolved in test context
      final medications = <Map<String, dynamic>>[
        {'displayName': 'Warfarin', 'drugClass': 'Vitamin K Antagonist'},
        {'displayName': 'Aspirin', 'drugClass': 'NSAID/Antiplatelet'},
      ];

      final result = checker.checkInteractions(medications);

      expect(result.hasInteractions, true);
      expect(result.hasMajorInteractions, true);
      expect(result.interactions.first.severity, InteractionSeverity.major);
    });

    test('detects moderate interaction (Ibuprofen + Lisinopril)', () {
      final medications = <Map<String, dynamic>>[
        {'displayName': 'Ibuprofen', 'drugClass': 'NSAID'},
        {'displayName': 'Lisinopril', 'drugClass': 'ACE Inhibitor'},
      ];

      final result = checker.checkInteractions(medications);

      expect(result.hasInteractions, true);
      expect(result.hasModerateInteractions, true);
    });

    test('returns no interactions for safe combination (Acetaminophen + Amoxicillin)', () {
      final medications = <Map<String, dynamic>>[
        {'displayName': 'Acetaminophen'},
        {'displayName': 'Amoxicillin'},
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
      final medications = <Map<String, dynamic>>[
        {'displayName': 'Unknown Drug A'},
        {'displayName': 'Unknown Drug B'},
      ];

      final result = checker.checkInteractions(medications);
      expect(result.hasInteractions, false);
    });

    test('generates critical insights for major interactions', () {
      final medications = <Map<String, dynamic>>[
        {'displayName': 'Warfarin', 'drugClass': 'Vitamin K Antagonist'},
        {'displayName': 'Aspirin', 'drugClass': 'NSAID/Antiplatelet'},
      ];

      final result = checker.checkInteractions(medications);
      final insights = checker.generateInsights(result);
      expect(insights.any((i) => i.severity == InsightSeverity.critical), true);
    });
  });

  group('DrugInteractionChecker - Drug-Condition Interactions', () {
    test('detects NSAID + Heart Failure contraindication', () {
      final medications = <Map<String, dynamic>>[
        {'displayName': 'Ibuprofen', 'drugClass': 'NSAID'},
      ];
      final conditions = [
        Icd10Code(code: 'I50.9', displayName: 'Heart Failure', category: 'Heart'),
      ];

      final warnings = checker.checkDrugConditionInteractions(medications, conditions);
      expect(warnings, isNotEmpty);
      expect(warnings.first.severity, InsightSeverity.warning);
      expect(warnings.first.description, contains('heart failure'));
    });

    test('detects NSAID + CKD contraindication', () {
      final medications = <Map<String, dynamic>>[
        {'displayName': 'Ibuprofen', 'drugClass': 'NSAID'},
      ];
      final conditions = [
        Icd10Code(code: 'N18.9', displayName: 'Chronic Kidney Disease', category: 'Renal'),
      ];

      final warnings = checker.checkDrugConditionInteractions(medications, conditions);
      expect(warnings, isNotEmpty);
      expect(warnings.first.severity, InsightSeverity.warning);
      expect(warnings.first.description, contains('kidney disease'));
    });

    test('detects pregnancy contraindications', () {
      final medications = <Map<String, dynamic>>[
        {'displayName': 'Lisinopril', 'drugClass': 'ACE inhibitor'},
      ];
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
