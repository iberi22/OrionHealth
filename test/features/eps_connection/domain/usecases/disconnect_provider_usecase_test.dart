import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/eps_connection/domain/repositories/oauth_repository.dart';
import 'package:orionhealth_health/features/eps_connection/domain/usecases/disconnect_provider_usecase.dart';
import 'package:orionhealth_health/features/user_profile/domain/entities/user_profile.dart';
import 'package:orionhealth_health/features/user_profile/domain/repositories/user_profile_repository.dart';

class MockOAuthRepository extends Mock implements OAuthRepository {}
class MockUserProfileRepository extends Mock implements UserProfileRepository {}

void main() {
  late DisconnectProviderUseCase useCase;
  late MockOAuthRepository mockOAuthRepository;
  late MockUserProfileRepository mockUserProfileRepository;

  final testProfile = UserProfile(
    name: 'Test',
    email: 'test@test.com',
    isEpsConnected: true,
    epsPatientId: 'PT-123',
  );

  setUpAll(() {
    registerFallbackValue(testProfile);
  });

  setUp(() {
    mockOAuthRepository = MockOAuthRepository();
    mockUserProfileRepository = MockUserProfileRepository();
    useCase = DisconnectProviderUseCase(mockOAuthRepository, mockUserProfileRepository);
  });

  test('should logout and update profile if no connections left', () async {
    when(() => mockOAuthRepository.logout(any())).thenAnswer((_) async => {});
    when(() => mockUserProfileRepository.getUserProfile()).thenAnswer((_) async => testProfile);
    when(() => mockOAuthRepository.getConnectedProviders()).thenAnswer((_) async => []);
    when(() => mockUserProfileRepository.saveUserProfile(any())).thenAnswer((_) async => {});

    await useCase('test_id');

    verify(() => mockOAuthRepository.logout('test_id')).called(1);
    verify(() => mockUserProfileRepository.saveUserProfile(any(
      that: isA<UserProfile>()
          .having((p) => p.isEpsConnected, 'isEpsConnected', false)
          .having((p) => p.epsPatientId, 'epsPatientId', isNull),
    ))).called(1);
  });

  test('should logout but NOT update profile if connections still exist', () async {
    when(() => mockOAuthRepository.logout(any())).thenAnswer((_) async => {});
    when(() => mockUserProfileRepository.getUserProfile()).thenAnswer((_) async => testProfile);
    when(() => mockOAuthRepository.getConnectedProviders()).thenAnswer((_) async => ['other_id']);

    await useCase('test_id');

    verify(() => mockOAuthRepository.logout('test_id')).called(1);
    verifyNever(() => mockUserProfileRepository.saveUserProfile(any()));
  });

  test('should handle missing profile gracefully', () async {
    when(() => mockOAuthRepository.logout(any())).thenAnswer((_) async => {});
    when(() => mockUserProfileRepository.getUserProfile()).thenAnswer((_) async => null);

    await useCase('test_id');

    verify(() => mockOAuthRepository.logout('test_id')).called(1);
    verifyNever(() => mockOAuthRepository.getConnectedProviders());
  });
}
