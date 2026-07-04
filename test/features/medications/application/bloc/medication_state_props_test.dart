import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/medications/application/bloc/medication_bloc.dart';
import 'package:orionhealth_health/features/medications/domain/entities/medication.dart';

void main() {
  group('MedicationState Props', () {
    test('MedicationInitial exists', () {
      expect(const MedicationState.initial(), isA<MedicationState>());
    });

    test('MedicationLoading exists', () {
      expect(const MedicationState.loading(), isA<MedicationState>());
    });

    test('MedicationLoaded holds medications', () {
      final medications = [
        Medication(
          name: 'N',
          startDate: DateTime(2024),
        )
      ];
      final state = MedicationState.loaded(medications);
      expect(state, isA<MedicationLoaded>());
      expect((state as MedicationLoaded).medications, medications);
    });

    test('MedicationError holds message', () {
      final state = MedicationState.error('error');
      expect(state, isA<MedicationError>());
      expect((state as MedicationError).message, 'error');
    });
  });
}
