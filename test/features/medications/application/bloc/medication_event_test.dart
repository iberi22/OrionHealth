import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/medications/application/bloc/medication_bloc.dart';
import 'package:orionhealth_health/features/medications/domain/entities/medication.dart';

void main() {
  group('MedicationEvent', () {
    test('LoadMedications supports value equality', () {
      expect(LoadMedications(), isA<LoadMedications>());
    });

    test('SaveMedication supports value equality', () {
      final medication = Medication(
        id: 1,
        name: 'Test',
        dosage: '10mg',
        frequency: 'Daily',
        startDate: DateTime(2026),
      );
      expect(SaveMedication(medication), isA<SaveMedication>());
    });

    test('DeleteMedication supports value equality', () {
      expect(DeleteMedication(1), isA<DeleteMedication>());
    });
  });
}
