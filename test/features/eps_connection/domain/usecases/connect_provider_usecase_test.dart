import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/eps_connection/domain/entities/eps_provider.dart';
import 'package:orionhealth_health/features/eps_connection/domain/entities/oauth_token.dart';
import 'package:orionhealth_health/features/eps_connection/domain/repositories/oauth_repository.dart';
import 'package:orionhealth_health/features/eps_connection/domain/usecases/connect_provider_usecase.dart';
import 'package:orionhealth_health/features/user_profile/domain/entities/user_profile.dart';
import 'package:orionhealth_health/features/user_profile/domain/repositories/user_profile_repository.dart';

class MockOAuthRepository extends Mock implements OAuthRepository {}
class MockUserProfileRepository extends Mock implements UserProfileRepository {}

void main() {
  late ConnectProviderUseCase useCase;
  late MockOAuthRepository mockOAuthRepository;
  late MockUserProfileRepository mockUserProfileRepository;

  final testProvider = const EPSProvider(
    id: 'test_id',
    name: 'Test EPS',
    discoveryUrl: 'D',
    clientId: 'C',
    redirectUrl: 'R',
    scopes: ['S'],
  );
  final testProfile = UserProfile(name: 'Test', email: 'test@test.com');

  setUpAll(() {
    registerFallbackValue(testProvider);
    registerFallbackValue(testProfile);
  });

  setUp(() {
    mockOAuthRepository = MockOAuthRepository();
    mockUserProfileRepository = MockUserProfileRepository();
    useCase = ConnectProviderUseCase(mockOAuthRepository, mockUserProfileRepository);
  });

  test('should login and update user profile on success', () async {
    when(() => mockOAuthRepository.login(any())).thenAnswer((_) async => OAuthLoginResult(
      token: const OAuthToken(accessToken: 'A'),
      patientId: 'PT-123',
    ));
    when(() => mockUserProfileRepository.getUserProfile()).thenAnswer((_) async => testProfile);
    when(() => mockUserProfileRepository.saveUserProfile(any())).thenAnswer((_) async => {});

    await useCase(testProvider);

    verify(() => mockOAuthRepository.login(testProvider)).called(1);
    verify(() => mockUserProfileRepository.getUserProfile()).called(1);
    verify(() => mockUserProfileRepository.saveUserProfile(any(
      that: predicate<UserProfile>((p) => p.epsPatientId == 'PT-123' && p.isEpsConnected == true),
    ))).called(1);
  });

  test('should throw exception if profile not found', () async {
    when(() => mockOAuthRepository.login(any())).thenAnswer((_) async => OAuthLoginResult(
      token: const OAuthToken(accessToken: 'A'),
      patientId: 'PT-123',
    ));
    when(() => mockUserProfileRepository.getUserProfile()).thenAnswer((_) async => null);

    expect(() => useCase(testProvider), throwsA(isA<Exception>()));
  });

  test('should do nothing if login returns null', () async {
    when(() => mockOAuthRepository.login(any())).thenAnswer((_) async => null);

    await useCase(testProvider);

    verify(() => mockOAuthRepository.login(testProvider)).called(1);
    verifyNever(() => mockUserProfileRepository.getUserProfile());
  });
}
