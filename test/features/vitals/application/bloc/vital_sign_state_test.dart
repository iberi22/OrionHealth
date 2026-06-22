import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/vitals/application/bloc/vital_sign_bloc.dart';
import 'package:orionhealth_health/features/vitals/domain/entities/vital_sign.dart';

void main() {
  group('VitalSignState', () {
    test('initial supports value equality', () {
      expect(const VitalSignState.initial(), const VitalSignState.initial());
    });

    test('loading supports value equality', () {
      expect(const VitalSignState.loading(), const VitalSignState.loading());
    });

    test('loaded supports value equality', () {
      final vitals = [
        VitalSign(
          id: 1,
          type: VitalSignType.heartRate,
          value: 70,
          unit: 'bpm',
          timestamp: DateTime.now(),
        )
      ];
      expect(VitalSignState.loaded(vitals), VitalSignState.loaded(vitals));
    });

    test('latestLoaded supports value equality', () {
      expect(const VitalSignState.latestLoaded({}), const VitalSignState.latestLoaded({}));
    });

    test('error supports value equality', () {
      expect(const VitalSignState.error('error'), const VitalSignState.error('error'));
    });
  });
}
