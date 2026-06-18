import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/vitals/application/vitals_state.dart';
import 'package:orionhealth_health/features/vitals/domain/entities/vital_sign.dart';

void main() {
  final now = DateTime(2026, 6, 18, 1, 0, 0);

  group('VitalsState', () {
    group('VitalsInitial', () {
      test('creates correctly', () {
        const state = VitalsInitial();
        expect(state.props, []);
      });

      test('is initial state', () {
        const state = VitalsInitial();
        expect(state, isA<VitalsInitial>());
      });
    });

    group('VitalsLoading', () {
      test('creates correctly', () {
        const state = VitalsLoading();
        expect(state.props, []);
      });

      test('is loading state', () {
        const state = VitalsLoading();
        expect(state, isA<VitalsLoading>());
      });
    });

    group('VitalsLoaded', () {
      final vital = VitalSign(
        type: VitalSignType.heartRate,
        value: 72,
        dateTime: now,
      );

      test('creates with vitals list', () {
        final state = VitalsLoaded([vital]);
        expect(state.vitals, [vital]);
        expect(state.props, [
          [vital],
        ]);
      });

      test('empty vitals list', () {
        final state = VitalsLoaded([]);
        expect(state.vitals, isEmpty);
      });
    });

    group('VitalsLatestLoaded', () {
      final vital = VitalSign(
        type: VitalSignType.heartRate,
        value: 72,
        dateTime: now,
      );

      test('creates with latest map', () {
        final latest = <VitalSignType, VitalSign?>{
          VitalSignType.heartRate: vital,
        };
        final state = VitalsLatestLoaded(latest);
        expect(state.latest, latest);
        expect(state.props, [latest]);
      });

      test('empty latest map', () {
        final state = VitalsLatestLoaded({});
        expect(state.latest, isEmpty);
      });
    });

    group('VitalsError', () {
      test('creates with error message', () {
        const state = VitalsError('Database error');
        expect(state.message, 'Database error');
        expect(state.props, ['Database error']);
      });

      test('empty error message', () {
        const state = VitalsError('');
        expect(state.message, '');
      });
    });

    group('Equality', () {
      test('VitalsInitial instances are equal', () {
        expect(const VitalsInitial(), equals(const VitalsInitial()));
      });

      test('VitalsLoading instances are equal', () {
        expect(const VitalsLoading(), equals(const VitalsLoading()));
      });

      test('VitalsLoaded with same vitals are equal', () {
        final a = VitalsLoaded([]);
        final b = VitalsLoaded([]);
        expect(a, equals(b));
      });

      test('VitalsLoaded with different vitals are not equal', () {
        final vital = VitalSign(
          type: VitalSignType.heartRate,
          value: 72,
          dateTime: now,
        );
        final a = VitalsLoaded([vital]);
        final b = VitalsLoaded([]);
        expect(a, isNot(equals(b)));
      });

      test('VitalsLatestLoaded with same maps are equal', () {
        final a = VitalsLatestLoaded({});
        final b = VitalsLatestLoaded({});
        expect(a, equals(b));
      });

      test('VitalsError with same message are equal', () {
        expect(const VitalsError('error'), equals(const VitalsError('error')));
      });

      test('VitalsError with different messages are not equal', () {
        expect(const VitalsError('a'), isNot(equals(const VitalsError('b'))));
      });
    });
  });
}
