import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/emergency/domain/entities/emergency_contact.dart';
import 'package:orionhealth_health/features/emergency/domain/entities/medical_condition.dart';
import 'package:orionhealth_health/features/emergency/domain/entities/medical_id.dart';

void main() {
  group('MedicalIdEntity', () {
    final id = MedicalIdEntity(
      userId: 'u1',
      fullName: 'Brahyan Belalcazar',
      dateOfBirth: DateTime(2000, 1, 1),
      bloodType: BloodType.oPositive,
      allergies: ['Penicillin', 'Peanuts'],
      currentMedications: ['Metformin'],
      chronicConditions: [
        MedicalCondition(
            name: 'Type 2 Diabetes',
            icd10Code: 'E11.9',
            severity: ConditionSeverity.moderate)
      ],
      primaryContact: const EmergencyContact(
        name: 'Maria Belalcazar',
        relationship: 'Madre',
        phone: '+57-300-123-4567',
      ),
      organDonor: OrganDonor.yes,
      lastUpdated: DateTime(2026, 8, 30),
    );

    test('age is computed from dateOfBirth', () {
      expect(id.age, greaterThan(20));
    });

    test('toCriticalCard returns 4 essential fields', () {
      final card = id.toCriticalCard();
      expect(card.length, 4);
      expect(card[0], 'Brahyan Belalcazar');
      expect(card[1], contains('O Positivo'));
      expect(card[2], contains('Penicillin'));
      expect(card[3], contains('Maria Belalcazar'));
    });

    test('copyWith updates only specified fields', () {
      final updated = id.copyWith(bloodType: BloodType.abNegative);
      expect(updated.bloodType, BloodType.abNegative);
      expect(updated.fullName, id.fullName); // unchanged
      expect(updated.lastUpdated, id.lastUpdated);
    });

    test('toJson + fromJson round-trip', () {
      final json = id.toJson();
      final restored = MedicalIdEntity.fromJson(json);
      expect(restored.userId, id.userId);
      expect(restored.bloodType, id.bloodType);
      expect(restored.allergies, id.allergies);
      expect(restored.organDonor, id.organDonor);
      expect(restored.primaryContact.phone, id.primaryContact.phone);
    });

    test('BloodType.fromCode handles unknown gracefully', () {
      expect(BloodType.fromCode('X+'), BloodType.unknown);
      expect(BloodType.fromCode('A+'), BloodType.aPositive);
    });
  });

  group('EmergencyContact', () {
    test('toJson + fromJson round-trip', () {
      const c = EmergencyContact(
        name: 'X',
        relationship: 'Padre',
        phone: '+57-1-123',
        email: 'x@example.com',
      );
      final restored = EmergencyContact.fromJson(c.toJson());
      expect(restored.email, 'x@example.com');
    });
  });

  group('MedicalCondition', () {
    test('toJson + fromJson round-trip', () {
      final c = MedicalCondition(
        name: 'Asthma',
        icd10Code: 'J45',
        severity: ConditionSeverity.mild,
      );
      final restored = MedicalCondition.fromJson(c.toJson());
      expect(restored.severity, ConditionSeverity.mild);
    });
  });
}
