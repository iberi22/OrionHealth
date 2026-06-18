import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/medications/domain/entities/medication.dart';

void main() {
  group('Medication', () {
    test('supports field equality', () {
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
      expect(med1.id, equals(med2.id));
      expect(med1.name, equals(med2.name));
      expect(med1.dosage, equals(med2.dosage));
      expect(med1.frequency, equals(med2.frequency));
      expect(med1.startDate, equals(med2.startDate));
      expect(med1.isActive, equals(med2.isActive));
      expect(med1.notes, equals(med2.notes));
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
