enum BmiCategory { underweight, normal, overweight, obese }

enum HeartRateZone { none, zone1, zone2, zone3, zone4, zone5 }

enum BloodPressureCategory { normal, elevated, stage1, stage2, crisis }

class VitalsCalculator {
  /// Calculates BMI using weight in kg and height in cm.
  static double calculateBMI(double weightKg, double heightCm) {
    if (heightCm <= 0 || weightKg <= 0) return 0;
    final heightMeters = heightCm / 100;
    return weightKg / (heightMeters * heightMeters);
  }

  /// Classifies BMI according to WHO standards.
  static BmiCategory classifyBMI(double bmi) {
    if (bmi < 18.5) return BmiCategory.underweight;
    if (bmi < 25.0) return BmiCategory.normal;
    if (bmi < 30.0) return BmiCategory.overweight;
    return BmiCategory.obese;
  }

  /// Calculates Heart Rate Zone based on percentage of Max HR (220 - age).
  ///
  /// Zone 1: 50–60% of MHR
  /// Zone 2: 60–70% of MHR
  /// Zone 3: 70–80% of MHR
  /// Zone 4: 80–90% of MHR
  /// Zone 5: 90–100% of MHR
  static HeartRateZone calculateHeartRateZone(int hr, int age) {
    if (age <= 0 || age > 120) return HeartRateZone.none;
    final maxHr = 220 - age;
    if (maxHr <= 0) return HeartRateZone.none;
    final percentage = (hr / maxHr) * 100;

    if (percentage < 50) return HeartRateZone.none;
    if (percentage < 60) return HeartRateZone.zone1;
    if (percentage < 70) return HeartRateZone.zone2;
    if (percentage < 80) return HeartRateZone.zone3;
    if (percentage < 90) return HeartRateZone.zone4;
    return HeartRateZone.zone5;
  }

  /// Classifies Blood Pressure according to AHA 2017 guidelines.
  static BloodPressureCategory classifyBloodPressure(double systolic, double diastolic) {
    if (systolic >= 180 || diastolic >= 120) return BloodPressureCategory.crisis;
    if (systolic >= 140 || diastolic >= 90) return BloodPressureCategory.stage2;
    if (systolic >= 130 || diastolic >= 80) return BloodPressureCategory.stage1;
    if (systolic >= 120 && diastolic < 80) return BloodPressureCategory.elevated;
    return BloodPressureCategory.normal;
  }

  /// Converts temperature between Celsius and Fahrenheit.
  static double convertTemperature(double value, {required bool toFahrenheit}) {
    if (toFahrenheit) {
      return (value * 9 / 5) + 32;
    } else {
      return (value - 32) * 5 / 9;
    }
  }
}
