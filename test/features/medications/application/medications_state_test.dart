import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/medications/application/medications_state.dart';
import 'package:orionhealth_health/features/medications/domain/entities/medication.dart';

void main() {
  group('MedicationsState', () {
    group('MedicationsInitial', () {
      test('supports value equality', () {
        expect(const MedicationsInitial(), equals(const MedicationsInitial()));
      });

      test('props are empty', () {
        expect(const MedicationsInitial().props, []);
      });
    });

    group('MedicationsLoading', () {
      test('supports value equality', () {
        expect(const MedicationsLoading(), equals(const MedicationsLoading()));
      });

      test('props are empty', () {
        expect(const MedicationsLoading().props, []);
      });
    });

    group('MedicationsLoaded', () {
      final medications = [
        Medication(id: 1, name: 'Losartan', startDate: DateTime.now()),
        Medication(id: 2, name: 'Metformina', startDate: DateTime.now()),
      ];

      test('supports value equality', () {
        expect(
          MedicationsLoaded(medications),
          equals(MedicationsLoaded(medications)),
        );
      });

      test('props are correct', () {
        expect(MedicationsLoaded(medications).props, [medications]);
      });

      test('different medications are not equal', () {
        expect(
          MedicationsLoaded(medications),
          isNot(equals(MedicationsLoaded([]))),
        );
      });
    });

    group('MedicationsError', () {
      test('supports value equality', () {
        expect(
          const MedicationsError('err'),
          equals(const MedicationsError('err')),
        );
      });

      test('different messages are not equal', () {
        expect(
          const MedicationsError('err1'),
          isNot(equals(const MedicationsError('err2'))),
        );
      });

      test('props contain message', () {
        expect(const MedicationsError('test error').props, ['test error']);
      });
    });
  });
}
