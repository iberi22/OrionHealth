import 'package:injectable/injectable.dart';
import 'package:medical_standards/medical_standards.dart';
import '../../domain/entities/medical_insight.dart';

/// Interprets laboratory results using LOINC codes and clinical guidelines
@injectable
class LabInterpreter {
  /// Interpret a single lab value
  LabInterpretation interpret({
    required String loincCode,
    required double value,
    String? gender,
    int? age,
  }) {
    final loinc = LoincCommonLabs.findByCode(loincCode);
    if (loinc == null) {
      return LabInterpretation(
        code: loincCode,
        value: value,
        status: LabStatus.unknown,
        message: 'Unknown lab code: $loincCode',
      );
    }

    return _interpretLoinc(loinc, value, gender: gender, age: age);
  }

  LabInterpretation _interpretLoinc(LoincCode loinc, double value, {String? gender, int? age}) {
    LabStatus status;
    final comments = <String>[];

    // Use hardcoded reference ranges for common labs
    final ranges = _getReferenceRange(loinc.code, gender: gender);
    final min = ranges.$1;
    final max = ranges.$2;
    final criticalLow = ranges.$3;
    final criticalHigh = ranges.$4;

    // Check critical values first
    if (criticalLow != null && value < criticalLow) {
      status = LabStatus.criticalLow;
      comments.add('⚠️ CRITICAL: Value below critical threshold');
    } else if (criticalHigh != null && value > criticalHigh) {
      status = LabStatus.criticalHigh;
      comments.add('⚠️ CRITICAL: Value above critical threshold');
    } else if (min != null && value < min) {
      status = LabStatus.low;
      comments.add('Below normal range ($min-${max ?? "N/A"} ${loinc.unit})');
    } else if (max != null && value > max) {
      status = LabStatus.high;
      comments.add('Above normal range (${min ?? "N/A"}-$max ${loinc.unit})');
    } else {
      status = LabStatus.normal;
      comments.add('Within normal range');
    }

    return LabInterpretation(
      code: loinc.code,
      value: value,
      unit: loinc.unit,
      status: status,
      displayName: loinc.displayName,
      message: comments.join('. '),
      referenceRange: min != null && max != null ? '$min - $max' : null,
    );
  }

  (double?, double?, double?, double?) _getReferenceRange(String code, {String? gender}) {
    switch (code) {
      case '718-7': // Hemoglobin
        if (gender?.toLowerCase() == 'male') return (13.5, 17.5, 7.0, 20.0);
        return (12.0, 16.0, 7.0, 20.0);
      case '4544-3': // Hematocrit
        if (gender?.toLowerCase() == 'male') return (38.0, 50.0, 20.0, 60.0);
        return (34.0, 44.0, 20.0, 60.0);
      case '6690-2': // WBC
        return (4.5, 11.0, 2.0, 30.0);
      case '777-3': // Platelets
        return (150.0, 400.0, 50.0, 1000.0);
      case '2345-7': // Glucose
        return (70.0, 100.0, 40.0, 400.0);
      case '4548-4': // HbA1c
        return (4.0, 5.6, 2.0, 14.0);
      case '2160-0': // Creatinine
        if (gender?.toLowerCase() == 'male') return (0.7, 1.3, 0.1, 10.0);
        return (0.6, 1.1, 0.1, 10.0);
      case '3094-0': // BUN
        return (7.0, 20.0, 3.0, 100.0);
      case '2951-2': // Sodium
        return (136.0, 145.0, 120.0, 160.0);
      case '2823-3': // Potassium
        return (3.5, 5.0, 2.5, 6.5);
      case '2093-3': // Total Cholesterol
        return (null, 200.0, null, null);
      case '13457-7': // LDL
        return (null, 100.0, null, null);
      case '2085-9': // HDL
        if (gender?.toLowerCase() == 'male') return (40.0, null, null, null);
        return (50.0, null, null, null);
      case '2571-8': // Triglycerides
        return (null, 150.0, null, null);
      case '3016-3': // TSH
        return (0.4, 4.0, 0.01, 20.0);
      case '3026-2': // Free T4
        return (0.8, 1.8, null, null);
      case '2276-4': // Ferritin
        if (gender?.toLowerCase() == 'male') return (20.0, 250.0, null, null);
        return (10.0, 120.0, null, null);
      case '2508-8': // Iron
        if (gender?.toLowerCase() == 'male') return (65.0, 175.0, null, null);
        return (50.0, 170.0, null, null);
      case '2502-1': // Iron Saturation
        return (20.0, 50.0, null, null);
      default:
        return (null, null, null, null);
    }
  }

  /// Interpret a complete metabolic panel
  List<LabInterpretation> interpretPanel(Map<String, double> values, {String? gender}) {
    return values.entries.map((e) => interpret(
      loincCode: e.key,
      value: e.value,
      gender: gender,
    )).toList();
  }

  /// Generate insights from lab interpretations
  List<MedicalInsight> generateInsights(List<LabInterpretation> interpretations) {
    return interpretations.map((i) => MedicalInsight(
      id: 'lab-insight-${i.code}',
      title: i.displayName ?? i.code,
      description: '${i.value} ${i.unit ?? ""} — ${i.message}',
      severity: _severityFromStatus(i.status),
      category: InsightCategory.labInterpretation,
      guidelineReference: ClinicalGuidelines.labReferenceRanges.code,
      recommendations: _recommendationsFromStatus(i.status, i.code),
      generatedAt: DateTime.now(),
      evidence: {'interpretation': i.status.name, 'reference': i.referenceRange},
    )).toList();
  }

  InsightSeverity _severityFromStatus(LabStatus status) {
    switch (status) {
      case LabStatus.criticalLow:
      case LabStatus.criticalHigh:
        return InsightSeverity.critical;
      case LabStatus.high:
      case LabStatus.low:
        return InsightSeverity.warning;
      case LabStatus.normal:
        return InsightSeverity.info;
      case LabStatus.unknown:
        return InsightSeverity.info;
    }
  }

  List<String> _recommendationsFromStatus(LabStatus status, String code) {
    switch (status) {
      case LabStatus.criticalLow:
      case LabStatus.criticalHigh:
        return ['Seek immediate medical attention', 'Contact your healthcare provider'];
      case LabStatus.high:
      case LabStatus.low:
        return ['Discuss with your healthcare provider', 'May need follow-up testing'];
      default:
        return ['Continue routine monitoring'];
    }
  }
}

/// Lab interpretation result
class LabInterpretation {
  final String code;
  final double value;
  final String? unit;
  final LabStatus status;
  final String? displayName;
  final String message;
  final String? referenceRange;

  const LabInterpretation({
    required this.code,
    required this.value,
    this.unit,
    required this.status,
    this.displayName,
    required this.message,
    this.referenceRange,
  });
}

/// Lab value status
enum LabStatus { normal, low, high, criticalLow, criticalHigh, unknown }
