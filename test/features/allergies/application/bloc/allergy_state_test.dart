import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/allergies/application/bloc/allergy_bloc.dart';
import 'package:orionhealth_health/features/allergies/domain/entities/allergy.dart';

void main() {
  group('AllergyState', () {
    test('initial supports value equality', () {
      expect(const AllergyState.initial(), const AllergyState.initial());
    });

    test('loading supports value equality', () {
      expect(const AllergyState.loading(), const AllergyState.loading());
    });

    test('loaded supports value equality', () {
      final allergies = [Allergy(id: 1, allergen: 'Peanuts')];
      expect(AllergyState.loaded(allergies), AllergyState.loaded(allergies));
    });

    test('error supports value equality', () {
      expect(const AllergyState.error('error'), const AllergyState.error('error'));
    });
  });
}
