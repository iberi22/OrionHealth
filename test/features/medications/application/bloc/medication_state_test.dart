import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/medications/application/bloc/medication_bloc.dart';
import 'package:orionhealth_health/features/medications/domain/entities/medication.dart';

void main() {
  group('MedicationState', () {
    test('initial supports value equality', () {
      expect(const MedicationState.initial(), const MedicationState.initial());
    });

    test('loading supports value equality', () {
      expect(const MedicationState.loading(), const MedicationState.loading());
    });

    test('loaded supports value equality', () {
      final medications = [
        Medication(
          id: 1,
          name: 'Test',
          dosage: '10mg',
          frequency: 'Daily',
        )
      ];
      expect(MedicationState.loaded(medications), MedicationState.loaded(medications));
    });

    test('error supports value equality', () {
      expect(const MedicationState.error('error'), const MedicationState.error('error'));
    });
  });
}
