import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/user_profile/domain/repositories/right_to_erasure_repository.dart';

class _MockRepo implements RightToErasureRepository {
  @override
  Future<ErasureCounts> eraseAllUserData(String userId) async {
    return ErasureCounts()
      ..userProfile = 1
      ..medicalRecords = 5
      ..medications = 3
      ..allergies = 2
      ..appointments = 10
      ..vitalSigns = 100
      ..reports = 4
      ..doctorProfiles = 2;
  }
}

void main() {
  group('ErasureCounts', () {
    test('total sums all collection counts', () {
      final counts = ErasureCounts()
        ..userProfile = 1
        ..medicalRecords = 5
        ..medications = 3
        ..allergies = 2
        ..appointments = 10
        ..vitalSigns = 100
        ..reports = 4
        ..doctorProfiles = 2;

      expect(counts.total, 127);
    });

    test('toJson includes all fields', () {
      final counts = ErasureCounts()
        ..userProfile = 1
        ..medicalRecords = 2;

      final json = counts.toJson();
      expect(json['user_profile'], 1);
      expect(json['medical_records'], 2);
      expect(json['total_db_records'], 3);
      expect(json.containsKey('secure_storage_keys_deleted'), true);
    });
  });

  group('RightToErasureRepository contract', () {
    late RightToErasureRepository repo;

    setUp(() {
      repo = _MockRepo();
    });

    test('eraseAllUserData returns ErasureCounts', () async {
      final counts = await repo.eraseAllUserData('test_user');
      expect(counts, isA<ErasureCounts>());
      expect(counts.total, greaterThan(0));
    });
  });
}