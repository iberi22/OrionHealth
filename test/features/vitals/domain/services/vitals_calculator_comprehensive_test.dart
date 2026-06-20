import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/vitals/domain/services/vitals_calculator.dart';

void main() {
  group('VitalsCalculator Comprehensive', () {
    group('Blood Pressure Classification', () {
      test('normal BP', () {
        expect(VitalsCalculator.classifyBloodPressure(119, 79), BloodPressureCategory.normal);
      });

      test('elevated BP', () {
        expect(VitalsCalculator.classifyBloodPressure(120, 79), BloodPressureCategory.elevated);
        expect(VitalsCalculator.classifyBloodPressure(129, 79), BloodPressureCategory.elevated);
      });

      test('stage 1 hypertension', () {
        expect(VitalsCalculator.classifyBloodPressure(130, 70), BloodPressureCategory.stage1);
        expect(VitalsCalculator.classifyBloodPressure(120, 80), BloodPressureCategory.stage1);
      });

      test('stage 2 hypertension', () {
        expect(VitalsCalculator.classifyBloodPressure(140, 70), BloodPressureCategory.stage2);
        expect(VitalsCalculator.classifyBloodPressure(120, 90), BloodPressureCategory.stage2);
      });

      test('hypertensive crisis', () {
        expect(VitalsCalculator.classifyBloodPressure(180, 100), BloodPressureCategory.crisis);
        expect(VitalsCalculator.classifyBloodPressure(140, 120), BloodPressureCategory.crisis);
      });
    });

    group('Heart Rate Zone Calculation', () {
      test('infant heart rate zone (very high HR, young age)', () {
        // Max HR = 220 - 1 = 219
        // 50% = 109.5
        expect(VitalsCalculator.calculateHeartRateZone(100, 1), HeartRateZone.none);
        expect(VitalsCalculator.calculateHeartRateZone(110, 1), HeartRateZone.zone1);
      });

      test('elderly heart rate zone', () {
        // Max HR = 220 - 100 = 120
        // 50% = 60, 60% = 72, 70% = 84, 80% = 96, 90% = 108
        expect(VitalsCalculator.calculateHeartRateZone(50, 100), HeartRateZone.none);
        expect(VitalsCalculator.calculateHeartRateZone(65, 100), HeartRateZone.zone1);
        expect(VitalsCalculator.calculateHeartRateZone(75, 100), HeartRateZone.zone2);
        expect(VitalsCalculator.calculateHeartRateZone(90, 100), HeartRateZone.zone3);
        expect(VitalsCalculator.calculateHeartRateZone(100, 100), HeartRateZone.zone4);
        expect(VitalsCalculator.calculateHeartRateZone(115, 100), HeartRateZone.zone5);
      });

      test('handles edge case age 120', () {
        // Max HR = 220 - 120 = 100
        expect(VitalsCalculator.calculateHeartRateZone(55, 120), HeartRateZone.zone1);
      });

      test('handles age > 120', () {
        expect(VitalsCalculator.calculateHeartRateZone(100, 121), HeartRateZone.none);
      });
    });

    group('BMI Edge Cases', () {
      test('extremely high weight/height', () {
        // 500kg, 100cm (1m) = 500 BMI
        expect(VitalsCalculator.calculateBMI(500, 100), 500);
        expect(VitalsCalculator.classifyBMI(500), BmiCategory.obese);
      });

      test('extremely low weight/height', () {
        // 1kg, 200cm (2m) = 1/4 = 0.25 BMI
        expect(VitalsCalculator.calculateBMI(1, 200), 0.25);
        expect(VitalsCalculator.classifyBMI(0.25), BmiCategory.underweight);
      });
    });

    group('Temperature Conversion Precision', () {
      test('water freezing point', () {
        expect(VitalsCalculator.convertTemperature(32, toFahrenheit: false), 0);
        expect(VitalsCalculator.convertTemperature(0, toFahrenheit: true), 32);
      });

      test('water boiling point', () {
        expect(VitalsCalculator.convertTemperature(212, toFahrenheit: false), 100);
        expect(VitalsCalculator.convertTemperature(100, toFahrenheit: true), 212);
      });

      test('absolute zero (approx)', () {
        // -273.15 C = -459.67 F
        expect(VitalsCalculator.convertTemperature(-273.15, toFahrenheit: true), closeTo(-459.67, 0.01));
        expect(VitalsCalculator.convertTemperature(-459.67, toFahrenheit: false), closeTo(-273.15, 0.01));
      });
    });
  });
}
