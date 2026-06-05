import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/vitals/domain/services/vitals_calculator.dart';

void main() {
  group('VitalsCalculator', () {
    group('BMI', () {
      test('calculateBMI returns correct value', () {
        // 70kg / (1.75m * 1.75m) = 22.857...
        expect(VitalsCalculator.calculateBMI(70, 175), closeTo(22.86, 0.01));
      });

      test('calculateBMI handles zero height', () {
        expect(VitalsCalculator.calculateBMI(70, 0), 0);
      });

      test('calculateBMI handles zero weight', () {
        expect(VitalsCalculator.calculateBMI(0, 175), 0);
      });

      test('classifyBMI returns correct categories', () {
        expect(VitalsCalculator.classifyBMI(16.0), BmiCategory.underweight);
        expect(VitalsCalculator.classifyBMI(18.4), BmiCategory.underweight);
        expect(VitalsCalculator.classifyBMI(18.5), BmiCategory.normal);
        expect(VitalsCalculator.classifyBMI(24.9), BmiCategory.normal);
        expect(VitalsCalculator.classifyBMI(25.0), BmiCategory.overweight);
        expect(VitalsCalculator.classifyBMI(29.9), BmiCategory.overweight);
        expect(VitalsCalculator.classifyBMI(30.0), BmiCategory.obese);
        expect(VitalsCalculator.classifyBMI(40.0), BmiCategory.obese);
      });
    });

    group('Heart Rate Zone', () {
      test('calculateHeartRateZone returns correct zones for 30 year old', () {
        // Max HR = 220 - 30 = 190
        // Zone 1: 50-60% (95-114)
        // Zone 2: 60-70% (114-133)
        // Zone 3: 70-80% (133-152)
        // Zone 4: 80-90% (152-171)
        // Zone 5: 90-100% (171-190)

        expect(VitalsCalculator.calculateHeartRateZone(90, 30), HeartRateZone.none);
        expect(VitalsCalculator.calculateHeartRateZone(100, 30), HeartRateZone.zone1);
        expect(VitalsCalculator.calculateHeartRateZone(120, 30), HeartRateZone.zone2);
        expect(VitalsCalculator.calculateHeartRateZone(140, 30), HeartRateZone.zone3);
        expect(VitalsCalculator.calculateHeartRateZone(160, 30), HeartRateZone.zone4);
        expect(VitalsCalculator.calculateHeartRateZone(180, 30), HeartRateZone.zone5);
      });

      test('calculateHeartRateZone handles invalid age', () {
        expect(VitalsCalculator.calculateHeartRateZone(100, 0), HeartRateZone.none);
        expect(VitalsCalculator.calculateHeartRateZone(100, -1), HeartRateZone.none);
        expect(VitalsCalculator.calculateHeartRateZone(100, 221), HeartRateZone.none);
      });
    });

    group('Blood Pressure', () {
      test('classifyBloodPressure returns correct categories', () {
        expect(VitalsCalculator.classifyBloodPressure(110, 70), BloodPressureCategory.normal);
        expect(VitalsCalculator.classifyBloodPressure(120, 75), BloodPressureCategory.elevated);
        expect(VitalsCalculator.classifyBloodPressure(130, 80), BloodPressureCategory.stage1);
        expect(VitalsCalculator.classifyBloodPressure(135, 85), BloodPressureCategory.stage1);
        expect(VitalsCalculator.classifyBloodPressure(140, 90), BloodPressureCategory.stage2);
        expect(VitalsCalculator.classifyBloodPressure(150, 95), BloodPressureCategory.stage2);
        expect(VitalsCalculator.classifyBloodPressure(180, 110), BloodPressureCategory.crisis);
        expect(VitalsCalculator.classifyBloodPressure(170, 120), BloodPressureCategory.crisis);
      });
    });

    group('Temperature Conversion', () {
      test('convertTemperature to Fahrenheit', () {
        expect(VitalsCalculator.convertTemperature(0, toFahrenheit: true), 32);
        expect(VitalsCalculator.convertTemperature(100, toFahrenheit: true), 212);
        expect(VitalsCalculator.convertTemperature(37, toFahrenheit: true), 98.6);
      });

      test('convertTemperature to Celsius', () {
        expect(VitalsCalculator.convertTemperature(32, toFahrenheit: false), 0);
        expect(VitalsCalculator.convertTemperature(212, toFahrenheit: false), 100);
        expect(VitalsCalculator.convertTemperature(98.6, toFahrenheit: false), closeTo(37, 0.1));
      });
    });
  });
}
