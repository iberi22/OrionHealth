import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/emergency/domain/entities/emergency_contact.dart';
import 'package:orionhealth_health/features/emergency/domain/entities/medical_id.dart';
import 'package:orionhealth_health/features/emergency/infrastructure/services/qr_generator_service.dart';

void main() {
  group('QrGeneratorService', () {
    final service = QrGeneratorService();
    final id = MedicalIdEntity(
      userId: 'u1',
      fullName: 'Juan Perez',
      dateOfBirth: DateTime(1990, 5, 15),
      bloodType: BloodType.oPositive,
      allergies: const ['Penicillin'],
      primaryContact: const EmergencyContact(
        name: 'Maria',
        relationship: 'Esposa',
        phone: '+57-300-999-8877',
      ),
      organDonor: OrganDonor.yes,
      lastUpdated: DateTime(2026, 8, 30),
    );

    test('generates ORIONMED:v1 prefix', () {
      final qr = service.generate(id);
      expect(qr.startsWith('ORIONMED:v1;'), true);
    });

    test('includes name, age, blood type', () {
      final qr = service.generate(id);
      expect(qr, contains('NAME=Juan Perez'));
      expect(qr, contains('AGE='));
      expect(qr, contains('BT=O+'));
    });

    test('includes allergies when present', () {
      final qr = service.generate(id);
      expect(qr, contains('AL=Penicillin'));
    });

    test('includes ICE contact', () {
      final qr = service.generate(id);
      expect(qr, contains('ICE=Maria'));
      expect(qr, contains('PHONE=+57-300-999-88'));
    });

    test('includes OD=YES when organ donor', () {
      final qr = service.generate(id);
      expect(qr, contains('OD=YES'));
    });

    test('omits OD when not organ donor', () {
      final notDonor = id.copyWith(organDonor: OrganDonor.no);
      final qr = service.generate(notDonor);
      expect(qr, isNot(contains('OD=YES')));
    });

    test('truncates very long values', () {
      final longId = id.copyWith(
        fullName: 'A' * 100,
        allergies: ['B' * 100],
      );
      final qr = service.generate(longId);
      // Truncated to 30 chars + '…' for name
      expect(qr.length, lessThan(300));
    });
  });
}
