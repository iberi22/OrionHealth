import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/medications/application/bloc/medication_bloc.dart';
import 'package:orionhealth_health/features/medications/domain/entities/medication.dart';

void main() {
  group('MedicationEvent Props', () {
    test('LoadMedications is an event', () {
      expect(LoadMedications(), isA<MedicationEvent>());
    });

    test('SaveMedication holds medication', () {
      final medication = Medication(
        name: 'N',
        startDate: DateTime(2024),
      );
      expect(SaveMedication(medication).medication, medication);
    });
  });
}
