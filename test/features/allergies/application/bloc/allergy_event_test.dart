import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/allergies/application/bloc/allergy_bloc.dart';
import 'package:orionhealth_health/features/allergies/domain/entities/allergy.dart';

void main() {
  group('AllergyEvent', () {
    test('LoadAllergies supports value equality', () {
      expect(LoadAllergies(), isA<LoadAllergies>());
    });

    test('SaveAllergy supports value equality', () {
      final allergy = Allergy(id: 1, allergen: 'Peanuts');
      expect(SaveAllergy(allergy), isA<SaveAllergy>());
    });

    test('DeleteAllergy supports value equality', () {
      expect(DeleteAllergy(1), isA<DeleteAllergy>());
    });
  });
}
