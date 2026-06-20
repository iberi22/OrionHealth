import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/user_profile/domain/entities/user_profile.dart';
import 'package:orionhealth_health/features/user_profile/infrastructure/repositories/user_profile_repository_impl.dart';

class MockIsar extends Mock implements Isar {
  @override
  Future<T> writeTxn<T>(Future<T> Function() callback, {bool silent = false}) {
    return callback();
  }
}

abstract class IsarCollectionUserProfile extends IsarCollection<UserProfile> {}
class MockIsarCollection extends Mock implements IsarCollectionUserProfile {}

class FakeUserProfile extends Fake implements UserProfile {}

void main() {
  late MockIsar mockIsar;
  late MockIsarCollection mockCollection;
  late UserProfileRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(FakeUserProfile());
  });

  setUp(() {
    mockIsar = MockIsar();
    mockCollection = MockIsarCollection();
    repository = UserProfileRepositoryImpl(mockIsar);

    when(() => mockIsar.userProfiles).thenReturn(mockCollection);
  });

  group('UserProfileRepositoryImpl Mocked', () {
    test('saveUserProfile calls put', () async {
      final profile = UserProfile(name: 'John Doe');
      when(() => mockCollection.put(any())).thenAnswer((_) async => 1);

      await repository.saveUserProfile(profile);

      verify(() => mockCollection.put(profile)).called(1);
    });

    test('deleteUserProfile calls clear', () async {
      when(() => mockCollection.clear()).thenAnswer((_) async => 0);

      await repository.deleteUserProfile();

      verify(() => mockCollection.clear()).called(1);
    });
  });
}
