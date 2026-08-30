import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/emergency/domain/entities/emergency_contact.dart';
import 'package:orionhealth_health/features/emergency/domain/entities/medical_id.dart';
import 'package:orionhealth_health/features/emergency/domain/repositories/medical_id_repository.dart';
import 'package:orionhealth_health/features/emergency/domain/usecases/get_medical_id_usecase.dart';
import 'package:orionhealth_health/features/emergency/domain/usecases/update_medical_id_usecase.dart';

class _MockRepo implements MedicalIdRepository {
  MedicalIdEntity? _stored;

  @override
  Future<MedicalIdEntity?> getByUser(String userId) async => _stored;

  @override
  Future<void> save(MedicalIdEntity medicalId) async {
    _stored = medicalId;
  }

  @override
  Future<void> delete(String userId) async {
    _stored = null;
  }

  @override
  Future<List<String>> getCriticalFields(String userId) async {
    return _stored?.toCriticalCard() ?? const [];
  }
}

MedicalIdEntity _sample() => MedicalIdEntity(
      userId: 'u1',
      fullName: 'Test User',
      dateOfBirth: DateTime(1990, 1, 1),
      bloodType: BloodType.aPositive,
      primaryContact: const EmergencyContact(
        name: 'ICE',
        relationship: 'friend',
        phone: '+1-555',
      ),
      lastUpdated: DateTime(2026, 8, 30),
    );

void main() {
  group('GetMedicalIdUseCase', () {
    test('returns null when not set', () async {
      final repo = _MockRepo();
      final useCase = GetMedicalIdUseCase(repo);
      expect(await useCase('u1'), null);
    });

    test('returns stored MedicalId', () async {
      final repo = _MockRepo();
      final id = _sample();
      await repo.save(id);
      final useCase = GetMedicalIdUseCase(repo);
      final result = await useCase('u1');
      expect(result?.fullName, 'Test User');
      expect(result?.bloodType, BloodType.aPositive);
    });
  });

  group('UpdateMedicalIdUseCase', () {
    test('saves with lastUpdated = now', () async {
      final repo = _MockRepo();
      final useCase = UpdateMedicalIdUseCase(repo);
      final before = DateTime.now();
      final id = _sample();
      await useCase(id);
      final after = DateTime.now();
      final stored = await repo.getByUser('u1');
      expect(stored, isNotNull);
      expect(
        stored!.lastUpdated.isAfter(before) ||
            stored.lastUpdated.isAtSameMomentAs(before),
        true,
      );
      expect(
        stored.lastUpdated.isBefore(after) ||
            stored.lastUpdated.isAtSameMomentAs(after),
        true,
      );
    });

    test('preserves other fields on save', () async {
      final repo = _MockRepo();
      final useCase = UpdateMedicalIdUseCase(repo);
      final id = _sample().copyWith(bloodType: BloodType.oNegative);
      await useCase(id);
      final stored = await repo.getByUser('u1');
      expect(stored?.bloodType, BloodType.oNegative);
      expect(stored?.fullName, 'Test User');
    });
  });
}
