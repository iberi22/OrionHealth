import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/allergies/application/allergies_state.dart';
import 'package:orionhealth_health/features/allergies/domain/entities/allergy.dart';

void main() {
  group('AllergiesState', () {
    group('AllergiesInitial', () {
      test('supports value equality', () {
        expect(const AllergiesInitial(), equals(const AllergiesInitial()));
      });
      test('props are empty', () {
        expect(const AllergiesInitial().props, []);
      });
    });

    group('AllergiesLoading', () {
      test('supports value equality', () {
        expect(const AllergiesLoading(), equals(const AllergiesLoading()));
      });
      test('props are empty', () {
        expect(const AllergiesLoading().props, []);
      });
    });

    group('AllergiesLoaded', () {
      final allergies = <Allergy>[
        Allergy(id: 1, allergen: 'Penicilina', severity: AllergySeverity.severe),
      ];

      test('supports value equality', () {
        expect(AllergiesLoaded(allergies), equals(AllergiesLoaded(allergies)));
      });

      test('props are correct', () {
        expect(AllergiesLoaded(allergies).props, [allergies]);
      });

      test('different allergies are not equal', () {
        expect(AllergiesLoaded(allergies), isNot(equals(AllergiesLoaded([]))));
      });
    });

    group('AllergiesError', () {
      test('supports value equality', () {
        expect(
          const AllergiesError('err'),
          equals(const AllergiesError('err')),
        );
      });
      test('different messages are not equal', () {
        expect(
          const AllergiesError('err1'),
          isNot(equals(const AllergiesError('err2'))),
        );
      });
      test('props contain message', () {
        expect(const AllergiesError('err').props, ['err']);
      });
    });
  });
}
