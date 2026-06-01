import 'package:medical_standards/medical_standards.dart';
import '../../domain/entities/medical_insight.dart';

/// Calculates various health risk scores
class RiskCalculator {
  /// Calculate 10-year ASCVD risk (American College of Cardiology/AHA)
  /// Uses the Pooled Cohort Equations
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

    return AscvdRisk(
      score: risk,
      category: _ascvdCategory(risk),
      guideline: ClinicalGuidelines.accAhaRiskCalculator,
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
    final lnAge = Math.log(age.toDouble());
    final dblAgeLn = Math.log(age.toDouble() * age.toDouble());

    // Clamp to physiological ranges
    final tc = totalCholesterol.clamp(130, 320);
    final hdl = hdlCholesterol.clamp(20, 100);
    final sbp = systolicBp.clamp(90, 200);

    // Pooled Cohort Equations linear predictor (ACC/AHA 2013)
    final lnTotal = Math.log(tc);
    final lnHdl = Math.log(hdl);
    final lnSbp = Math.log(sbp);

    final sum = 12.344
        + 2.76889 * lnAge
        + 0.940 * dblAgeLn
        + 0.05486 * age.toDouble()
        + 0.04826 * (tc - 170) / 30
        - 0.6534 * (hdl - 50) / 20
        + (onBpMeds ? 0.01499 * (sbp - 120) : 0.01876 * (sbp - 120))
        + (hasDiabetes ? 0.69196 : 0.0)
        + (isSmoker ? 0.65484 : 0.0);

    // Mean baseline survival at 10 years for males
    const baselineSurvival = 0.9144;
    return (1 - Math.pow(baselineSurvival, Math.exp(sum))) * 100;
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
    final lnAge = Math.log(age.toDouble());

    // Clamp to physiological ranges
    final tc = totalCholesterol.clamp(130, 320);
    final hdl = hdlCholesterol.clamp(20, 100);
    final sbp = systolicBp.clamp(90, 200);

    final lnTotal = Math.log(tc);
    final lnHdl = Math.log(hdl);
    final lnSbp = Math.log(sbp);

    final sum = -29.799
        + 4.884 * lnAge
        + 13.540 * Math.log(age.toDouble() * age.toDouble())
        + 0.05486 * age.toDouble()
        + 4.47264 * Math.log(tc / 200)
        - 16.1869 * Math.log(hdl / 50)
        + (onBpMeds ? 2.54890 * Math.log(sbp / 90) : 2.78956 * Math.log(sbp / 90))
        + (hasDiabetes ? 0.87682 : 0.0)
        + (isSmoker ? 0.69196 : 0.0);

    // Mean baseline survival at 10 years for females
    const baselineSurvival = 0.9665;
    return (1 - Math.pow(baselineSurvival, Math.exp(sum))) * 100;
  }

  String _ascvdCategory(double risk) {
    if (risk < 5) return 'Low risk (<5%)';
    if (risk < 7.5) return 'Borderline risk (5-7.5%)';
    if (risk < 20) return 'Intermediate risk (7.5-20%)';
    return 'High risk (>=20%)';
  }

  // ... (rest of file unchanged: QDiabetes, Hypertension, insights, Math class)
