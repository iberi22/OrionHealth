import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/user_profile/domain/services/user_profile_service.dart';
import 'package:orionhealth_health/features/user_profile/domain/repositories/user_profile_repository.dart';

class MockUserProfileRepository extends Mock implements UserProfileRepository {}

void main() {
  late UserProfileService service;
  late MockUserProfileRepository mockRepository;

  setUp(() {
    mockRepository = MockUserProfileRepository();
    service = UserProfileService(mockRepository);
  });

  test('getProfile calls repository', () async {
    when(() => mockRepository.getUserProfile()).thenAnswer((_) async => null);
    await service.getProfile();
    verify(() => mockRepository.getUserProfile()).called(1);
  });
}
