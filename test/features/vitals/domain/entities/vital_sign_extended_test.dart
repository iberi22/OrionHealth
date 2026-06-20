import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/vitals/domain/entities/vital_sign.dart';

void main() {
  group('VitalSign Extended', () {
    final now = DateTime.now();

    test('formattedValue handles all VitalSignType values', () {
      for (final type in VitalSignType.values) {
        final vital = VitalSign(
          type: type,
          value: 10.0,
          dateTime: now,
        );
        // Should not throw and should return a non-empty string
        expect(vital.formattedValue, isNotEmpty);
      }
    });

    test('formattedValue handles large values correctly', () {
      final vital = VitalSign(
        type: VitalSignType.steps,
        value: 1000000,
        dateTime: now,
      );
      expect(vital.formattedValue, '1000000 steps');
    });

    test('formattedValue handles decimal values for heart rate (int cast)', () {
      final vital = VitalSign(
        type: VitalSignType.heartRate,
        value: 72.9,
        dateTime: now,
      );
      expect(vital.formattedValue, '72 bpm');
    });

    test('formattedValue handles zero values', () {
      final vital = VitalSign(
        type: VitalSignType.bloodGlucose,
        value: 0,
        dateTime: now,
      );
      expect(vital.formattedValue, '0 mg/dL');
    });

    test('id can be set and retrieved', () {
      final vital = VitalSign(
        type: VitalSignType.heartRate,
        value: 72,
        dateTime: now,
      );
      vital.id = 123;
      expect(vital.id, 123);
    });

    test('supports setting all fields via constructor', () {
      final vital = VitalSign(
        type: VitalSignType.spO2,
        value: 99,
        dateTime: now,
        unit: '%',
        source: 'Sensor',
        notes: 'Feeling good',
      );
      expect(vital.type, VitalSignType.spO2);
      expect(vital.value, 99);
      expect(vital.dateTime, now);
      expect(vital.unit, '%');
      expect(vital.source, 'Sensor');
      expect(vital.notes, 'Feeling good');
    });
  });
}
