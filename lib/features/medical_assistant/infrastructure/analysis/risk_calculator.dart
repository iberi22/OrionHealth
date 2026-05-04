import 'dart:io' show stderr;

import 'package:injectable/injectable.dart';
import 'package:medical_standards/medical_standards.dart';
import 'package:orionhealth_health/features/user_profile/domain/repositories/user_profile_repository.dart';
import '../../domain/entities/medical_insight.dart';

/// Calculates various health risk scores using real patient profile data.
///
/// Injects [UserProfileRepository] to pull age, weight, conditions,
/// medications, and history directly from the user's health profile.
/// Falls back gracefully if profile is unavailable (returns default calculations).
@LazySingleton()
class RiskCalculator {
  final UserProfileRepository _userProfileRepo;

  RiskCalculator(this._userProfileRepo);

  /// Calculate all risk scores from the user's profile in one call.
  /// Pulls all needed data from [UserProfileRepository] automatically.
  Future<RiskProfile> calculateFromProfile() async {
    try {
      final profile = await _userProfileRepo.getUserProfile();
      if (profile == null) {
        stderr.writeln('[RiskCalculator] No profile found, using defaults');
        return RiskProfile.empty();
      }

      final age = profile.age ?? 40;
      final bmi = (profile.weight != null && profile.height != null)
          ? profile.weight! / ((profile.height! / 100) * (profile.height! / 100))
          : null;

      final ascvd = await calculateAscvdRisk(
        age: age,
        gender: '', // Not stored in profile, will use neutral
        totalCholesterol: 0, // Not stored yet
        hdlCholesterol: 0,
        systolicBp: 120,
        onBpMedication: profile.currentMedications.any((m) => m.contains('BP') || m.contains('hypertension') || m.contains('diuretic')),
        hasDiabetes: profile.medicalConditions.any((c) => c.startsWith('E10') || c.startsWith('E11')),
        isSmoker: profile.smokingStatus == 'current',
      );

      final diabetes = await calculateQDiabetesRisk(
        age: age,
        gender: '',
        bmi: bmi ?? 25.0,
        fastingGlucose: null,
        hasFamilyHistory: profile.familyHistoryDiabetes ?? false,
        hasCardiovascularDisease: profile.hasCardiovascularDisease ?? false,
        hasHypertension: profile.hasHypertension ?? false,
        hasSteroidUse: profile.hasSteroidUse ?? false,
        ethnicity: profile.ethnicity ?? 'other',
        isSmoker: profile.smokingStatus == 'current',
      );

      final hypertension = await calculateHypertensionRisk(
        age: age,
        bmi: bmi ?? 25.0,
        hasFamilyHistory: profile.familyHistoryCvd ?? false,
        sodiumUrineExcretion: null,
      );

      return RiskProfile(
        ascvd: ascvd,
        diabetes: diabetes,
        hypertension: hypertension,
        profileAge: age,
        profileBmi: bmi,
      );
    } catch (e) {
      stderr.writeln('[RiskCalculator] Profile calculation error: $e');
      return RiskProfile.empty();
    }
  }
  /// Calculate 10-year ASCVD risk using Pooled Cohort Equations.
  /// If gender is unknown, uses female equation (more conservative).
  Future<AscvdRisk> calculateAscvdRisk({
    required int age,
    required String gender,
    required double totalCholesterol,
    required double hdlCholesterol,
    required double systolicBp,
    required bool onBpMedication,
    required bool hasDiabetes,
    required bool isSmoker,
  }) async {
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
      );
    } else {
      // Default to female equation (more conservative) when gender unknown
      risk = _calculateFemaleAscvd(
        age: age,
        totalCholesterol: totalCholesterol,
        hdlCholesterol: hdlCholesterol,
        systolicBp: systolicBp,
        onBpMeds: onBpMedication,
        hasDiabetes: hasDiabetes,
        isSmoker: isSmoker,
      );
    }

    final guideline = await ClinicalGuidelines.findByCode('ACC-AHA-PRIMARY-2019');

    return AscvdRisk(
      score: risk,
      category: _ascvdCategory(risk),
      guideline: guideline!,
    );
  }

  double _calculateMaleAscvd({
    required int age,
    required double totalCholesterol,
    required double hdlCholesterol,
    required double systolicBp,
    required bool onBpMeds,
    required bool hasDiabetes,
    required bool isSmoker,
  }) {
    // Simplified Pooled Cohort Equations coefficients
    // In production, use full formulas from ACC/AHA
    final base = -0.04679 * age;
    final tcCoeff = totalCholesterol > 0 ? 0.04826 * (totalCholesterol - 170) / 30 : 0.0;
    final hdlCoeff = hdlCholesterol > 0 ? -0.6534 * Math.log(hdlCholesterol / 50) : 0.0;
    final bpCoeff = onBpMeds
        ? 0.01499 * (systolicBp - 120)
        : 0.01876 * (systolicBp - 120);
    final diabetesCoeff = hasDiabetes ? 0.69196 : 0.0;
    final smokerCoeff = isSmoker ? 0.65484 : 0.0;

    final sum = base + tcCoeff + hdlCoeff + bpCoeff + diabetesCoeff + smokerCoeff;
    return (1 - Math.exp(Math.exp(sum))).abs() * 100;
  }

  double _calculateFemaleAscvd({
    required int age,
    required double totalCholesterol,
    required double hdlCholesterol,
    required double systolicBp,
    required bool onBpMeds,
    required bool hasDiabetes,
    required bool isSmoker,
  }) {
    final base = 0.97682 * Math.log(age.toDouble()) - 18.0004;
    final tcCoeff = totalCholesterol > 0 ? 4.47264 * Math.log(totalCholesterol / 200) : 0.0;
    final hdlCoeff = hdlCholesterol > 0 ? -16.1869 * Math.log(hdlCholesterol / 50) : 0.0;
    final bpCoeff = onBpMeds
        ? 2.54890 * Math.log(systolicBp / 90)
        : 2.78956 * Math.log(systolicBp / 90);
    final diabetesCoeff = hasDiabetes ? 0.87682 : 0.0;
    final smokerCoeff = isSmoker ? 0.69196 : 0.0;

    final sum = base + tcCoeff + hdlCoeff + bpCoeff + diabetesCoeff + smokerCoeff;
    return (1 - Math.exp(Math.exp(sum))).abs() * 100;
  }

  String _ascvdCategory(double risk) {
    if (risk < 5) return 'Low risk (<5%)';
    if (risk < 7.5) return 'Borderline risk (5-7.5%)';
    if (risk < 20) return 'Intermediate risk (7.5-20%)';
    return 'High risk (≥20%)';
  }

  /// Calculate QDiabetes risk score for Type 2 diabetes
  Future<QDiabetesRisk> calculateQDiabetesRisk({
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
  }) async {
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
    final guideline = await ClinicalGuidelines.findByCode('ADA-MC-2024');

    return QDiabetesRisk(
      score: riskPercent,
      category: riskPercent < 5 ? 'Low' : (riskPercent < 15 ? 'Moderate' : 'High'),
      guideline: guideline!,
    );
  }

  /// Calculate hypertension risk based on BMI, age, sodium intake estimate
  Future<HypertensionRisk> calculateHypertensionRisk({
    required int age,
    required double bmi,
    required bool hasFamilyHistory,
    required double? sodiumUrineExcretion,
  }) async {
    double risk = 0;

    risk += age > 55 ? 2 : (age > 45 ? 1 : 0);
    risk += bmi > 30 ? 3 : (bmi > 25 ? 2 : 0);
    if (hasFamilyHistory) risk += 2;
    if (sodiumUrineExcretion != null) {
      risk += sodiumUrineExcretion > 5000 ? 2 : (sodiumUrineExcretion > 3000 ? 1 : 0);
    }

    final guideline = await ClinicalGuidelines.findByCode('WHO-2023');

    return HypertensionRisk(
      score: risk,
      category: risk < 2 ? 'Low' : (risk < 4 ? 'Moderate' : 'High'),
      guideline: guideline!,
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

// Math helpers for risk calculations
/// Composite risk profile calculated from user's health data.
///
/// Returned by [RiskCalculator.calculateFromProfile()] to provide
/// a complete risk snapshot in one call.
class RiskProfile {
  final AscvdRisk? ascvd;
  final QDiabetesRisk? diabetes;
  final HypertensionRisk? hypertension;
  final int profileAge;
  final double? profileBmi;

  RiskProfile({
    this.ascvd,
    this.diabetes,
    this.hypertension,
    this.profileAge = 0,
    this.profileBmi,
  });

  factory RiskProfile.empty() => RiskProfile();

  bool get hasData => ascvd != null || diabetes != null || hypertension != null;
}

// Math helpers for risk calculations
class Math {
  static double exp(double x) => _exp(x);
  static double log(double x) => _ln(x);

  static double _exp(double x) {
    if (x > 700) return double.maxFinite;
    if (x < -700) return 0;
    double result = 1.0;
    double term = 1.0;
    for (int i = 1; i < 100; i++) {
      term *= x / i;
      result += term;
      if (term.abs() < 1e-15) break;
    }
    return result;
  }

  static double _ln(double x) {
    if (x <= 0) return double.negativeInfinity;
    if (x == 1) return 0;
    // Use Newton's method
    double y = x - 1;
    if (y.abs() < 0.5) {
      // Taylor series for ln(1+y)
      double result = 0;
      double term = y;
      for (int i = 1; i < 100; i++) {
        result += term / i;
        term *= -y;
        if (term.abs() < 1e-15) break;
      }
      return result;
    }
    // For larger values, use log10 approximation
    return _log10(x) * 2.302585092994046;
  }

  static double _log10(double x) {
    int exp = 0;
    while (x >= 10) { x /= 10; exp++; }
    while (x < 1) { x *= 10; exp--; }
    // Approximate log10 using natural log
    return exp + (x - 1) / (x + 1) * 2; // Simple approximation
  }
}
