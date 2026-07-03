import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/medications/medications.dart';

void main() {
  group('Medications Feature Exports', () {
    test('should export all necessary classes', () {
      // Entities
      expect(Medication, isNotNull);

      // Repositories
      expect(MedicationRepository, isNotNull);
      expect(IsarMedicationRepository, isNotNull);

      // Application
      expect(MedicationsCubit, isNotNull);
      expect(MedicationsInitial, isNotNull);
      expect(MedicationBloc, isNotNull);

      // Presentation
      expect(MedicationsPage, isNotNull);
    });
  });
}
