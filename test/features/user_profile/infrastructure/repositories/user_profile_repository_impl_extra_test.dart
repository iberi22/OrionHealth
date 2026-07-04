import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/user_profile/infrastructure/repositories/user_profile_repository_impl.dart';

class MockIsar extends Mock implements Isar {}

void main() {
  late UserProfileRepositoryImpl repository;
  late MockIsar mockIsar;

  setUp(() {
    mockIsar = MockIsar();
    repository = UserProfileRepositoryImpl(mockIsar);
  });

  test('repository can be instantiated', () {
    expect(repository, isNotNull);
  });
}
