import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/medications/domain/entities/medication.dart';

void main() {
  group('Medication', () {
    test('supports property comparison', () {
      final now = DateTime.now();
      final med1 = Medication(
        id: 1,
        name: 'Ibuprofeno',
        dosage: '400mg',
        frequency: 'Cada 8 horas',
        startDate: now,
        isActive: true,
        notes: 'Tomar con comida',
      );
      final med2 = Medication(
        id: 1,
        name: 'Ibuprofeno',
        dosage: '400mg',
        frequency: 'Cada 8 horas',
        startDate: now,
        isActive: true,
        notes: 'Tomar con comida',
      );

      expect(med1.id, med2.id);
      expect(med1.name, med2.name);
      expect(med1.dosage, med2.dosage);
      expect(med1.frequency, med2.frequency);
      expect(med1.startDate, med2.startDate);
      expect(med1.isActive, med2.isActive);
      expect(med1.notes, med2.notes);
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
      expect(med1.id, isNot(med2.id));
      expect(med1.name, isNot(med2.name));
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
