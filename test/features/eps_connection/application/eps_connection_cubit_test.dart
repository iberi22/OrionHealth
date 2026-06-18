import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/eps_connection/application/bloc/eps_connection_cubit.dart';
import 'package:orionhealth_health/features/eps_connection/application/bloc/eps_connection_state.dart';
import 'package:orionhealth_health/features/eps_connection/domain/entities/eps_provider.dart';
import 'package:orionhealth_health/features/eps_connection/domain/entities/oauth_token.dart';
import 'package:orionhealth_health/features/eps_connection/domain/repositories/oauth_repository.dart';
import 'package:orionhealth_health/features/user_profile/domain/entities/user_profile.dart';
import 'package:orionhealth_health/features/user_profile/domain/repositories/user_profile_repository.dart';

class MockOAuthRepository extends Mock implements OAuthRepository {}
class MockUserProfileRepository extends Mock implements UserProfileRepository {}

void main() {
  late EpsConnectionCubit cubit;
  late MockOAuthRepository mockOAuthRepository;
  late MockUserProfileRepository mockUserProfileRepository;

  final testProfile = UserProfile(
    name: 'Test User',
    email: 'test@example.com',
  );

  final testProvider = EPSProvider(
    id: 'test_id',
    name: 'Test EPS',
    discoveryUrl: 'https://test.com',
    clientId: 'client',
    redirectUrl: 'url',
    scopes: const ['scope'],
  );

  final testToken = const OAuthToken(accessToken: 'token');

  setUpAll(() {
    registerFallbackValue(testProfile);
    registerFallbackValue(testProvider);
  });

  setUp(() {
    mockOAuthRepository = MockOAuthRepository();
    mockUserProfileRepository = MockUserProfileRepository();

    when(() => mockOAuthRepository.getConnectedProviders()).thenAnswer((_) async => []);
  });

  Future<void> buildCubit() async {
    cubit = EpsConnectionCubit(mockOAuthRepository, mockUserProfileRepository);
    await Future.delayed(Duration.zero);
  }

  group('EpsConnectionCubit', () {
    test('loadConnections fetches all details and patient ID', () async {
      when(() => mockOAuthRepository.getConnectedProviders()).thenAnswer((_) async => ['test_id']);
      when(() => mockOAuthRepository.getToken('test_id')).thenAnswer((_) async => testToken);
      when(() => mockOAuthRepository.getProviderDetails('test_id')).thenAnswer((_) async => testProvider);
      when(() => mockOAuthRepository.getPatientId('test_id')).thenAnswer((_) async => 'PT-123');

      await buildCubit();

      final state = cubit.state as EpsConnectionLoaded;
      expect(state.connections.length, 1);
      expect(state.connections.first.patientId, 'PT-123');
      expect(state.connections.first.provider.name, 'Test EPS');
    });

    test('connect uses patient ID from login result', () async {
      when(() => mockUserProfileRepository.getUserProfile()).thenAnswer((_) async => testProfile);
      when(() => mockOAuthRepository.login(any())).thenAnswer((_) async => OAuthLoginResult(token: testToken, patientId: 'PT-123'));
      when(() => mockUserProfileRepository.saveUserProfile(any())).thenAnswer((_) async => {});
      when(() => mockOAuthRepository.getConnectedProviders()).thenAnswer((_) async => []);

      await buildCubit();
      await cubit.connect(testProvider);

      verify(() => mockUserProfileRepository.saveUserProfile(any(
        that: isA<UserProfile>().having((p) => p.epsPatientId, 'epsPatientId', 'PT-123')
      ))).called(1);
    });
  });
}
