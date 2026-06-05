import 'package:injectable/injectable.dart';
import '../../infrastructure/analysis/risk_calculator.dart';

/// Domain service for health risk assessments.
///
/// Wraps the infrastructure-level [RiskCalculator] to provide
/// a domain-friendly interface.
@injectable
class RiskCalculatorService {
  final RiskCalculator _calculator;

  RiskCalculatorService({RiskCalculator? calculator})
      : _calculator = calculator ?? RiskCalculator();

  /// Calculate 10-year ASCVD risk (American College of Cardiology/AHA)
  AscvdRisk calculateAscvdRisk({
    required int age,
    required String gender,
    required double totalCholesterol,
    required double hdlCholesterol,
    required double systolicBp,
    required bool onBpMedication,
    required bool hasDiabetes,
    required bool isSmoker,
  }) {
    // Basic domain validation/normalization
    final normalizedGender = gender.toLowerCase().trim();
    final constrainedAge = age.clamp(20, 79); // ASCVD is validated for 20-79

    return _calculator.calculateAscvdRisk(
      age: constrainedAge,
      gender: normalizedGender,
      totalCholesterol: totalCholesterol,
      hdlCholesterol: hdlCholesterol,
      systolicBp: systolicBp,
      onBpMedication: onBpMedication,
      hasDiabetes: hasDiabetes,
      isSmoker: isSmoker,
    );
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
    return _calculator.calculateQDiabetesRisk(
      age: age.clamp(25, 84),
      gender: gender,
      bmi: bmi.clamp(10, 60),
      fastingGlucose: fastingGlucose,
      hasFamilyHistory: hasFamilyHistory,
      hasCardiovascularDisease: hasCardiovascularDisease,
      hasHypertension: hasHypertension,
      hasSteroidUse: hasSteroidUse,
      ethnicity: ethnicity,
      isSmoker: isSmoker,
    );
  }

  /// Calculate hypertension risk
  HypertensionRisk calculateHypertensionRisk({
    required int age,
    required double bmi,
    required bool hasFamilyHistory,
    required double? sodiumUrineExcretion,
  }) {
    return _calculator.calculateHypertensionRisk(
      age: age.clamp(0, 120),
      bmi: bmi.clamp(10, 60),
      hasFamilyHistory: hasFamilyHistory,
      sodiumUrineExcretion: sodiumUrineExcretion,
    );
  }
}
