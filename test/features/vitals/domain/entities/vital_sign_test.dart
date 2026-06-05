import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/vitals/domain/entities/vital_sign.dart';

void main() {
  group('VitalSign', () {
    final now = DateTime.now();

    test('formattedValue returns correct string for heartRate', () {
      final vital = VitalSign(
        type: VitalSignType.heartRate,
        value: 72,
        dateTime: now,
      );
      expect(vital.formattedValue, '72 bpm');
    });

    test('formattedValue returns correct string for temperature', () {
      final vital = VitalSign(
        type: VitalSignType.temperature,
        value: 36.6,
        dateTime: now,
      );
      expect(vital.formattedValue, '36.6°C');
    });

    test('formattedValue returns correct string for systolic BP', () {
      final vital = VitalSign(
        type: VitalSignType.bloodPressureSystolic,
        value: 120,
        dateTime: now,
      );
      expect(vital.formattedValue, '120 mmHg');
    });

    test('formattedValue returns correct string for diastolic BP', () {
      final vital = VitalSign(
        type: VitalSignType.bloodPressureDiastolic,
        value: 80,
        dateTime: now,
      );
      expect(vital.formattedValue, '80 mmHg');
    });

    test('formattedValue returns correct string for spO2', () {
      final vital = VitalSign(
        type: VitalSignType.spO2,
        value: 98,
        dateTime: now,
      );
      expect(vital.formattedValue, '98%');
    });

    test('formattedValue returns correct string for oxygenSaturation', () {
      final vital = VitalSign(
        type: VitalSignType.oxygenSaturation,
        value: 97,
        dateTime: now,
      );
      expect(vital.formattedValue, '97%');
    });

    test('formattedValue returns correct string for steps', () {
      final vital = VitalSign(
        type: VitalSignType.steps,
        value: 10000,
        dateTime: now,
      );
      expect(vital.formattedValue, '10000 steps');
    });

    test('formattedValue returns correct string for sleep', () {
      final vital = VitalSign(
        type: VitalSignType.sleep,
        value: 480,
        dateTime: now,
      );
      expect(vital.formattedValue, '480 min');
    });

    test('formattedValue returns correct string for bloodGlucose', () {
      final vital = VitalSign(
        type: VitalSignType.bloodGlucose,
        value: 90,
        dateTime: now,
      );
      expect(vital.formattedValue, '90 mg/dL');
    });
  });
}
