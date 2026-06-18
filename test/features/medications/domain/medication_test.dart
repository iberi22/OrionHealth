import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/medications/domain/entities/medication.dart';

void main() {
  group('Medication', () {
    test('supports value equality', () {
      final now = DateTime.now();
      expect(
        Medication(
          id: 1,
          name: 'Ibuprofeno',
          dosage: '400mg',
          frequency: 'Cada 8 horas',
          startDate: now,
          isActive: true,
          notes: 'Tomar con comida',
        ),
        Medication(
          id: 1,
          name: 'Ibuprofeno',
          dosage: '400mg',
          frequency: 'Cada 8 horas',
          startDate: now,
          isActive: true,
          notes: 'Tomar con comida',
        ),
      );
    });

    test('supports different values', () {
      final now = DateTime.now();
      final med1 = Medication(
        id: 1,
        name: 'Ibuprofeno',
        startDate: now,
      );
      final med2 = Medication(
        id: 2,
        name: 'Paracetamol',
        startDate: now,
      );
      expect(med1, isNot(equals(med2)));
    });

    test('default values are correct', () {
      final now = DateTime.now();
      final medication = Medication(
        name: 'Test',
        startDate: now,
      );
      expect(medication.isActive, true);
      expect(medication.dosage, isNull);
      expect(medication.frequency, isNull);
      expect(medication.notes, isNull);
    });
  });
}
