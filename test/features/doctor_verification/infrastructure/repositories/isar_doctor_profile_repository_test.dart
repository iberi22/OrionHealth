import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/doctor_verification/domain/entities/doctor_profile.dart';
import 'package:orionhealth_health/features/doctor_verification/infrastructure/repositories/isar_doctor_profile_repository.dart';

class MockIsar extends Mock implements Isar {
  @override
  Future<T> writeTxn<T>(Future<T> Function() callback, {bool silent = false}) {
    return callback();
  }
}

abstract class IsarCollectionDoctorProfile extends IsarCollection<DoctorProfile> {}
class MockIsarCollection extends Mock implements IsarCollectionDoctorProfile {}

class FakeDoctorProfile extends Fake implements DoctorProfile {}

void main() {
  late MockIsar mockIsar;
  late MockIsarCollection mockCollection;
  late IsarDoctorProfileRepository repository;

  setUpAll(() {
    registerFallbackValue(FakeDoctorProfile());
  });

  setUp(() {
    mockIsar = MockIsar();
    mockCollection = MockIsarCollection();
    repository = IsarDoctorProfileRepository(mockIsar);

    when(() => mockIsar.doctorProfiles).thenReturn(mockCollection);
  });

  group('IsarDoctorProfileRepository', () {
    test('saveDoctorProfile puts profile in collection', () async {
      final profile = DoctorProfile(
        id: '1',
        fullName: 'Dr. House',
        specialty: 'Diagnostics',
        countryCode: 'US',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      when(() => mockCollection.put(any())).thenAnswer((_) async => 1);

      await repository.saveDoctorProfile(profile);

      verify(() => mockCollection.put(profile)).called(1);
    });
  });
}
