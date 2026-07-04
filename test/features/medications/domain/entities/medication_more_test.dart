import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/medications/domain/entities/medication.dart';

void main() {
  group('Medication More Tests', () {
    test('supports value equality', () {
      final m1 = Medication(
        id: 1,
        name: 'Aspirin',
        dosage: '100mg',
        frequency: 'Daily',
        startDate: DateTime(2024),
      );
      final m2 = Medication(
        id: 1,
        name: 'Aspirin',
        dosage: '100mg',
        frequency: 'Daily',
        startDate: DateTime(2024),
      );
      expect(m1 == m2, isTrue);
    });

    test('hashCode is consistent', () {
      final m1 = Medication(
        id: 1,
        name: 'Aspirin',
        dosage: '100mg',
        frequency: 'Daily',
        startDate: DateTime(2024),
      );
      final m2 = Medication(
        id: 1,
        name: 'Aspirin',
        dosage: '100mg',
        frequency: 'Daily',
        startDate: DateTime(2024),
      );
      expect(m1.hashCode, m2.hashCode);
    });
  });
}
