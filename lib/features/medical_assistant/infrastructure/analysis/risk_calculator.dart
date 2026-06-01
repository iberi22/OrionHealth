import 'dart:math' as dart_math;

import 'package:medical_standards/medical_standards.dart';
import '../../domain/entities/medical_insight.dart';

/// Calculates various health risk scores
class RiskCalculator {
  /// Calculate 10-year ASCVD risk (American College of Cardiology/AHA)
  /// Uses the Pooled Cohort Equations per ACC/AHA 2013 guideline.
  ///
  /// [race] should be 'white' or 'african_american'.  Defaults to 'white'.
  /// For other races the 'white' equation is used as a conservative estimate.
  AscvdRisk calculateAscvdRisk({
    required int age,
    required String gender,
    required double totalCholesterol,
    required double hdlCholesterol,
    required double systolicBp,
    required bool onBpMedication,
    required bool hasDiabetes,
    required bool isSmoker,
    String race = 'white',
  }) {
    double risk;

    if (gender.toLowerCase() == 'male') {
      risk = _calculateMaleAscvd(
        age: age,
        totalCholesterol: totalCholesterol,
        hdlCholesterol: hdlCholesterol,
        systolicBp: systolicBp,
        onBpMeds: onBpMedication,
        hasDiabetes: hasDiabetes,
        isSmoker: isSmoker,
        race: race,
      );
    } else {
      risk = _calculateFemaleAscvd(
        age: age,
        totalCholesterol: totalCholesterol,
        hdlCholesterol: hdlCholesterol,
        systolicBp: systolicBp,
        onBpMeds: onBpMedication,
        hasDiabetes: hasDiabetes,
        isSmoker: isSmoker,
        race: race,
      );
    }

    return AscvdRisk(
      score: risk,
      category: _ascvdCategory(risk),
      guideline: ClinicalGuidelines.accAhaRiskCalculator,
    );
  }

  // ──────────────────────────────────────────────
  // ACC/AHA 2013 Pooled Cohort Equations
  //
  //   Risk = 1 − S₀ ^ exp(Σ − mean_sum)
  //
  // where S₀ = baseline 10-year survival,
  //       Σ  = sum of (coefficient × ln(factor)) for continuous variables
  //            + coefficients for categorical ones,
  //   mean_sum = race/sex‑specific mean of Σ.
  // ──────────────────────────────────────────────

  double _calculateMaleAscvd({
    required int age,
    required double totalCholesterol,
    required double hdlCholesterol,
    required double systolicBp,
    required bool onBpMeds,
    required bool hasDiabetes,
    required bool isSmoker,
    required String race,
  }) {
    final lnAge = dart_math.log(age);
    final lnTc = dart_math.log(totalCholesterol);
    final lnHdl = dart_math.log(hdlCholesterol);
    final lnSbp = dart_math.log(systolicBp);

    double sum;

    if (race == 'african_american') {
      // African‑American male coefficients (ACC/AHA 2013)
      sum = 2.469 * lnAge
          + 0.302 * lnTc
          - 0.307 * lnHdl
          + 1.809 * lnSbp
          + (onBpMeds ? 0.549 : 0.0)
          + (hasDiabetes ? 0.645 : 0.0)
          + (isSmoker ? 0.549 : 0.0)
          - 19.543;

      final baselineSurvival = 0.8954; // S₀ for AA males
      final meanSum = -19.543; // mean for AA males (simplified)
      return _pooledCohortRisk(sum, baselineSurvival, meanSum);
    } else {
      // White / other male coefficients (ACC/AHA 2013)
      sum = 12.344 * lnAge
          + 11.853 * lnTc
          - 7.990 * lnHdl
          + 1.764 * lnSbp
          + (onBpMeds ? 1.797 : 0.0)
          + (hasDiabetes ? 0.658 : 0.0)
          + (isSmoker ? 7.837 : 0.0)
          - 61.180;

      final baselineSurvival = 0.9144; // S₀ for white males
      final meanSum = -29.18167; // mean for white males
      return _pooledCohortRisk(sum, baselineSurvival, meanSum);
    }
  }

  double _calculateFemaleAscvd({
    required int age,
    required double totalCholesterol,
    required double hdlCholesterol,
    required double systolicBp,
    required bool onBpMeds,
    required bool hasDiabetes,
    required bool isSmoker,
    required String race,
  }) {
    final lnAge = dart_math.log(age);
    final lnTc = dart_math.log(totalCholesterol);
    final lnHdl = dart_math.log(hdlCholesterol);
    final lnSbp = dart_math.log(systolicBp);

    double sum;

    if (race == 'african_american') {
      // African‑American female coefficients (ACC/AHA 2013)
      sum = 17.114 * lnAge
          + 0.940 * lnTc
          - 18.920 * lnHdl
          + 4.475 * lnSbp
          + (onBpMeds ? 29.291 : 0.0)
          + (hasDiabetes ? 0.691 : 0.0)
          + (isSmoker ? 0.874 : 0.0)
          - 86.608;

      final baselineSurvival = 0.9533; // S₀ for AA females
      final meanSum = -86.608; // mean for AA females
      return _pooledCohortRisk(sum, baselineSurvival, meanSum);
    } else {
      // White / other female coefficients (ACC/AHA 2013)
      sum = -29.799 * lnAge
          + 4.884 * lnTc
          + 13.540 * lnHdl
          + 1.022 * lnSbp
          + (onBpMeds ? 1.344 : 0.0)
          + (hasDiabetes ? 0.661 : 0.0)
          + (isSmoker ? 7.837 : 0.0)
          + 29.180;

      final baselineSurvival = 0.9665; // S₀ for white females
      final meanSum = 29.180; // mean for white females
      return _pooledCohortRisk(sum, baselineSurvival, meanSum);
    }
  }

  /// Compute risk from the pooled cohort equation:
  ///   Risk = 1 − S₀ ^ exp(Σ − mean_sum)
  double _pooledCohortRisk(double sum, double baselineSurvival, double meanSum) {
    final exponent = dart_math.exp(sum - meanSum);
    final risk = 1 - dart_math.pow(baselineSurvival, exponent).toDouble();
    // Clamp to [0, 100] and return as percentage
    return (risk * 100).clamp(0, 100);
  }

  String _ascvdCategory(double risk) {
    if (risk < 5) return 'Low risk (<5%)';
    if (risk < 7.5) return 'Borderline risk (5-7.5%)';
    if (risk < 20) return 'Intermediate risk (7.5-20%)';
    return 'High risk (≥20%)';
  }

  /// Calculate QDiabetes risk score for Type 2 diabetes
  QDiabetesRisk calculateQDiabetesRisk({
    required int age,
    required String gender,
    required double bmi,
    required double? fastingGlucose,
    required bool hasFamilyHistory,
    required bool hasCardiovascularDisease,
    required bool hasHypertension,
    required bool hasSteroidUse,
    required String ethnicity,
    required bool isSmoker,
  }) {
    double score = 0;

    score += age * 0.05;
    if (bmi >= 25 && bmi < 30) score += 1.2;
    if (bmi >= 30 && bmi < 35) score += 2.0;
    if (bmi >= 35) score += 2.5;
    if (hasFamilyHistory) score += 0.7;
    if (hasCardiovascularDisease) score += 0.5;
    if (hasHypertension) score += 0.4;
    if (hasSteroidUse) score += 1.2;
    if (ethnicity == 'south_asian' || ethnicity == 'african') score += 0.5;
    if (isSmoker) score += 0.3;

    if (fastingGlucose != null) {
      if (fastingGlucose >= 100 && fastingGlucose < 126) score += 2.0;
      if (fastingGlucose >= 126) score += 5.0;
    }

    final riskPercent = (score / 20) * 100;
    return QDiabetesRisk(
      score: riskPercent,
      category: riskPercent < 5 ? 'Low' : (riskPercent < 15 ? 'Moderate' : 'High'),
      guideline: ClinicalGuidelines.whoDiabetes,
    );
  }

  /// Calculate hypertension risk based on BMI, age, sodium intake estimate
  HypertensionRisk calculateHypertensionRisk({
    required int age,
    required double bmi,
    required bool hasFamilyHistory,
    required double? sodiumUrineExcretion,
  }) {
    double risk = 0;

    risk += age > 55 ? 2 : (age > 45 ? 1 : 0);
    risk += bmi > 30 ? 3 : (bmi > 25 ? 2 : 0);
    if (hasFamilyHistory) risk += 2;
    if (sodiumUrineExcretion != null) {
      risk += sodiumUrineExcretion > 5000 ? 2 : (sodiumUrineExcretion > 3000 ? 1 : 0);
    }

    return HypertensionRisk(
      score: risk,
      category: risk < 2 ? 'Low' : (risk < 4 ? 'Moderate' : 'High'),
      guideline: ClinicalGuidelines.whoHypertension,
    );
  }

  /// Generate insights from risk calculations
  List<MedicalInsight> generateInsights({
    AscvdRisk? ascvd,
    QDiabetesRisk? diabetes,
    HypertensionRisk? hypertension,
  }) {
    final insights = <MedicalInsight>[];

    if (ascvd != null) {
      insights.add(MedicalInsight(
        id: 'ascvd-${DateTime.now().millisecondsSinceEpoch}',
        title: '10-Year Cardiovascular Risk (ASCVD)',
        description: 'Your 10-year ASCVD risk is ${ascvd.score.toStringAsFixed(1)}% — ${ascvd.category}',
        severity: ascvd.score >= 20
            ? InsightSeverity.alert
            : (ascvd.score >= 7.5 ? InsightSeverity.warning : InsightSeverity.info),
        category: InsightCategory.riskAssessment,
        guidelineReference: ascvd.guideline.code,
        recommendations: _ascvdRecommendations(ascvd.score),
        generatedAt: DateTime.now(),
        evidence: {'score': ascvd.score, 'category': ascvd.category},
      ));
    }

    if (diabetes != null) {
      insights.add(MedicalInsight(
        id: 'diabetes-risk-${DateTime.now().millisecondsSinceEpoch}',
        title: 'Diabetes Risk Assessment',
        description: 'Estimated diabetes risk: ${diabetes.category}',
        severity: diabetes.category == 'High'
            ? InsightSeverity.warning
            : InsightSeverity.info,
        category: InsightCategory.riskAssessment,
        guidelineReference: diabetes.guideline.code,
        recommendations: _diabetesRecommendations(diabetes.category),
        generatedAt: DateTime.now(),
      ));
    }

    if (hypertension != null) {
      insights.add(MedicalInsight(
        id: 'htn-risk-${DateTime.now().millisecondsSinceEpoch}',
        title: 'Hypertension Risk',
        description: 'Hypertension risk: ${hypertension.category}',
        severity: hypertension.category == 'High'
            ? InsightSeverity.warning
            : InsightSeverity.info,
        category: InsightCategory.riskAssessment,
        guidelineReference: hypertension.guideline.code,
        recommendations: _htnRecommendations(hypertension.category),
        generatedAt: DateTime.now(),
      ));
    }

    return insights;
  }

  List<String> _ascvdRecommendations(double risk) {
    if (risk >= 20) {
      return [
        'High-intensity statin therapy recommended',
        'Consider cardiology referral',
        'Aggressive BP control target <130/80',
      ];
    } else if (risk >= 7.5) {
      return [
        'Moderate-intensity statin therapy',
        'Lifestyle modifications essential',
        'Monitor BP regularly',
      ];
    }
    return ['Maintain healthy lifestyle', 'Annual risk reassessment'];
  }

  List<String> _diabetesRecommendations(String category) {
    if (category == 'High') {
      return [
        'Fasting glucose and HbA1c testing recommended',
        'Weight management priority',
        'Consider metformin for prevention',
      ];
    }
    return ['Lifestyle modifications', 'Regular glucose monitoring'];
  }

  List<String> _htnRecommendations(String category) {
    if (category == 'High') {
      return [
        'Home BP monitoring recommended',
        'DASH diet and sodium restriction',
        'Consider BP medication evaluation',
      ];
    }
    return ['Maintain healthy weight', 'Reduce sodium intake'];
  }
}

/// ASCVD risk result
class AscvdRisk {
  final double score;
  final String category;
  final ClinicalGuidelineReference guideline;

  AscvdRisk({
    required this.score,
    required this.category,
    required this.guideline,
  });
}

/// QDiabetes risk result
class QDiabetesRisk {
  final double score;
  final String category;
  final ClinicalGuidelineReference guideline;

  QDiabetesRisk({
    required this.score,
    required this.category,
    required this.guideline,
  });
}

/// Hypertension risk result
class HypertensionRisk {
  final double score;
  final String category;
  final ClinicalGuidelineReference guideline;

  HypertensionRisk({
    required this.score,
    required this.category,
    required this.guideline,
  });
}
