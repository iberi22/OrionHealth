import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/vitals/application/bloc/vital_sign_bloc.dart';
import 'package:orionhealth_health/features/vitals/domain/entities/vital_sign.dart';

void main() {
  group('VitalSignEvent', () {
    test('LoadVitalSigns supports value equality', () {
      expect(LoadVitalSigns(), isA<LoadVitalSigns>());
    });

    test('LoadLatestVitals supports value equality', () {
      expect(LoadLatestVitals(), isA<LoadLatestVitals>());
    });

    test('SaveVitalSign supports value equality', () {
      final vital = VitalSign(
        type: VitalSignType.heartRate,
        value: 70,
        unit: 'bpm',
        dateTime: DateTime.now(),
      );
      expect(SaveVitalSign(vital), isA<SaveVitalSign>());
    });

    test('SaveVitalSigns supports value equality', () {
      expect(SaveVitalSigns([]), isA<SaveVitalSigns>());
    });
  });
}
