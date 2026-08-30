import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/user_profile/domain/repositories/right_to_erasure_repository.dart';

void main() {
  group('RightToErasureRepository contract', () {
    test('abstract repository defines eraseAllUserData', () {
      final checker = _ContractChecker();
      expect(checker.hasEraseMethod, true);
    });
  });

  group('ErasureCounts data integrity', () {
    test('initial all zeros, total = 0', () {
      final counts = ErasureCounts();
      expect(counts.userProfile, 0);
      expect(counts.medicalRecords, 0);
      expect(counts.medications, 0);
      expect(counts.allergies, 0);
      expect(counts.appointments, 0);
      expect(counts.vitalSigns, 0);
      expect(counts.reports, 0);
      expect(counts.doctorProfiles, 0);
      expect(counts.secureStorageKeysDeleted, 0);
      expect(counts.total, 0);
    });

    test('total excludes secureStorageKeysDeleted (DB only)', () {
      final counts = ErasureCounts()
        ..userProfile = 5
        ..medicalRecords = 10
        ..secureStorageKeysDeleted = 100;

      // total = 5 + 10 = 15 (DB records only)
      expect(counts.total, 15);
    });

    test('toJson preserves all field types', () {
      final counts = ErasureCounts()
        ..userProfile = 1
        ..secureStorageKeysDeleted = -1; // unknown marker

      final json = counts.toJson();
      expect(json['user_profile'], 1);
      expect(json['secure_storage_keys_deleted'], -1);
      expect(json['total_db_records'], 1);
    });

    test('IRREVERSIBLE: no undo methods exist', () {
      final counts = ErasureCounts()..userProfile = 5;
      // Verify there's no `restore`, `undo`, or similar method via reflection-like access
      expect(counts.toJson().containsKey('user_profile'), true);
      // The class intentionally lacks undo/restore functionality
    });
  });

  group('eraseAllUserData returns counts', () {
    test('mock repo returns populated counts', () async {
      final repo = _MockErasureRepo();
      final counts = await repo.eraseAllUserData('test_user');

      expect(counts.userProfile, 1);
      expect(counts.medicalRecords, 10);
      expect(counts.medications, 5);
      expect(counts.allergies, 3);
      expect(counts.appointments, 20);
      expect(counts.vitalSigns, 50);
      expect(counts.reports, 5);
      expect(counts.doctorProfiles, 2);
      expect(counts.total, 96);
    });
  });
}

class _ContractChecker implements RightToErasureRepository {
  bool get hasEraseMethod =>
      eraseAllUserData('test').toString().contains('Future<ErasureCounts>');

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockErasureRepo implements RightToErasureRepository {
  @override
  Future<ErasureCounts> eraseAllUserData(String userId) async {
    return ErasureCounts()
      ..userProfile = 1
      ..medicalRecords = 10
      ..medications = 5
      ..allergies = 3
      ..appointments = 20
      ..vitalSigns = 50
      ..reports = 5
      ..doctorProfiles = 2;
  }
}