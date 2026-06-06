import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/eps_connection/domain/eps_connection_cubit.dart';
import 'package:orionhealth_health/features/eps_connection/infrastructure/oauth_repository.dart';
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

  setUpAll(() {
    registerFallbackValue(testProfile);
  });

  setUp(() {
    mockOAuthRepository = MockOAuthRepository();
    mockUserProfileRepository = MockUserProfileRepository();
  });

  Future<void> buildCubit() async {
    cubit = EpsConnectionCubit(mockOAuthRepository, mockUserProfileRepository);
    // Wait for _checkInitialState to complete
    await Future.delayed(Duration.zero);
  }

  group('EpsConnectionCubit', () {
    test('initial state is EpsConnectionDisconnected when profile has no EPS data', () async {
      when(() => mockUserProfileRepository.getUserProfile())
          .thenAnswer((_) async => testProfile);

      await buildCubit();

      expect(cubit.state, isA<EpsConnectionDisconnected>());
    });

    test('initial state is EpsConnectionConnected when profile has EPS data', () async {
      final connectedProfile = testProfile.copyWith(
        isEpsConnected: true,
        epsPatientId: 'PT-123',
      );
      when(() => mockUserProfileRepository.getUserProfile())
          .thenAnswer((_) async => connectedProfile);

      await buildCubit();

      expect(cubit.state, const EpsConnectionConnected('PT-123'));
    });

    test('connect success emits Loading then Connected', () async {
      when(() => mockUserProfileRepository.getUserProfile())
          .thenAnswer((_) async => testProfile);
      await buildCubit();

      final response = AuthorizationTokenResponse(
        'access', 'refresh', DateTime.now(), 'id', 'type', null,
        {'patient': 'PT-123'},
        null,
      );

      when(() => mockOAuthRepository.login()).thenAnswer((_) async => response);
      when(() => mockUserProfileRepository.saveUserProfile(any()))
          .thenAnswer((_) async => {});

      final expectation = [
        const EpsConnectionLoading(),
        const EpsConnectionConnected('PT-123'),
      ];

      expectLater(cubit.stream, emitsInOrder(expectation));

      await cubit.connect();

      verify(() => mockUserProfileRepository.saveUserProfile(any(
        that: isA<UserProfile>().having((p) => p.epsPatientId, 'epsPatientId', 'PT-123')
                               .having((p) => p.isEpsConnected, 'isEpsConnected', true)
      ))).called(1);
    });

    test('connect failure (no patient ID in map) emits Error', () async {
      when(() => mockUserProfileRepository.getUserProfile())
          .thenAnswer((_) async => testProfile);
      await buildCubit();

      final response = AuthorizationTokenResponse(
        'access', 'refresh', DateTime.now(), 'id', 'type', null,
        {}, // Empty map
        null,
      );

      when(() => mockOAuthRepository.login()).thenAnswer((_) async => response);

      final expectation = [
        const EpsConnectionLoading(),
        const EpsConnectionError('No se pudo obtener el ID del paciente desde IHCE.'),
      ];

      expectLater(cubit.stream, emitsInOrder(expectation));

      await cubit.connect();
    });

    test('connect failure (getUserProfile throws during connect) emits Error', () async {
      when(() => mockUserProfileRepository.getUserProfile()).thenAnswer((_) async => testProfile);
      await buildCubit();

      final response = AuthorizationTokenResponse(
        'access', 'refresh', DateTime.now(), 'id', 'type', null,
        {'patient': 'PT-123'},
        null,
      );

      when(() => mockOAuthRepository.login()).thenAnswer((_) async => response);
      when(() => mockUserProfileRepository.getUserProfile()).thenAnswer((_) async => throw Exception('Fetch error during connect'));

      final expectation = [
        const EpsConnectionLoading(),
        isA<EpsConnectionError>().having((e) => e.message, 'message', contains('Fetch error during connect')),
      ];

      expectLater(cubit.stream, emitsInOrder(expectation));

      await cubit.connect();
    });

    test('connect failure (patient ID is not a string) emits Error', () async {
      when(() => mockUserProfileRepository.getUserProfile())
          .thenAnswer((_) async => testProfile);
      await buildCubit();

      final response = AuthorizationTokenResponse(
        'access', 'refresh', DateTime.now(), 'id', 'type', null,
        {'patient': 123}, // Int instead of String
        null,
      );

      when(() => mockOAuthRepository.login()).thenAnswer((_) async => response);

      final expectation = [
        const EpsConnectionLoading(),
        isA<EpsConnectionError>().having((e) => e.message, 'message', contains('is not a subtype of type')),
      ];

      expectLater(cubit.stream, emitsInOrder(expectation));

      await cubit.connect();
    });

    test('connect failure (login returns null) emits Disconnected', () async {
      when(() => mockUserProfileRepository.getUserProfile())
          .thenAnswer((_) async => testProfile);
      await buildCubit();

      when(() => mockOAuthRepository.login()).thenAnswer((_) async => null);

      final expectation = [
        const EpsConnectionLoading(),
        const EpsConnectionDisconnected(),
      ];

      expectLater(cubit.stream, emitsInOrder(expectation));

      await cubit.connect();
    });

    test('connect failure (no local profile) emits Error', () async {
      // First call for initial state
      when(() => mockUserProfileRepository.getUserProfile()).thenAnswer((_) async => testProfile);
      await buildCubit();

      final response = AuthorizationTokenResponse(
        'access', 'refresh', DateTime.now(), 'id', 'type', null,
        {'patient': 'PT-123'},
        null,
      );

      when(() => mockOAuthRepository.login()).thenAnswer((_) async => response);
      // Second call during connect
      when(() => mockUserProfileRepository.getUserProfile()).thenAnswer((_) async => null);

      final expectation = [
        const EpsConnectionLoading(),
        const EpsConnectionError('No se encontró el perfil de usuario local.'),
      ];

      expectLater(cubit.stream, emitsInOrder(expectation));

      await cubit.connect();
    });

    test('connect exception emits Error', () async {
      when(() => mockUserProfileRepository.getUserProfile())
          .thenAnswer((_) async => testProfile);
      await buildCubit();

      when(() => mockOAuthRepository.login()).thenThrow(Exception('Network error'));

      final expectation = [
        const EpsConnectionLoading(),
        anyOf(
          isA<EpsConnectionError>().having((e) => e.message, 'message', contains('Network error')),
        ),
      ];

      expectLater(cubit.stream, emitsInOrder(expectation));

      await cubit.connect();
    });

    test('disconnect success updates profile and emits Disconnected', () async {
      final connectedProfile = testProfile.copyWith(
        isEpsConnected: true,
        epsPatientId: 'PT-123',
      );
      when(() => mockUserProfileRepository.getUserProfile())
          .thenAnswer((_) async => connectedProfile);

      await buildCubit();

      when(() => mockOAuthRepository.logout()).thenAnswer((_) async => {});
      when(() => mockUserProfileRepository.getUserProfile())
          .thenAnswer((_) async => connectedProfile);
      when(() => mockUserProfileRepository.saveUserProfile(any()))
          .thenAnswer((_) async => {});

      final expectation = [
        const EpsConnectionLoading(),
        const EpsConnectionDisconnected(),
      ];

      expectLater(cubit.stream, emitsInOrder(expectation));

      await cubit.disconnect();

      verify(() => mockOAuthRepository.logout()).called(1);
      verify(() => mockUserProfileRepository.saveUserProfile(any(
        that: isA<UserProfile>().having((p) => p.isEpsConnected, 'isEpsConnected', false)
      ))).called(1);
    });

    test('disconnect exception emits Error', () async {
      when(() => mockUserProfileRepository.getUserProfile())
          .thenAnswer((_) async => testProfile);
      await buildCubit();

      when(() => mockOAuthRepository.logout()).thenThrow(Exception('Logout error'));

      final expectation = [
        const EpsConnectionLoading(),
        isA<EpsConnectionError>().having((e) => e.message, 'message', contains('Logout error')),
      ];

      expectLater(cubit.stream, emitsInOrder(expectation));

      await cubit.disconnect();
    });

    test('connect failure (saveUserProfile throws) emits Error', () async {
      when(() => mockUserProfileRepository.getUserProfile())
          .thenAnswer((_) async => testProfile);
      await buildCubit();

      final response = AuthorizationTokenResponse(
        'access', 'refresh', DateTime.now(), 'id', 'type', null,
        {'patient': 'PT-123'},
        null,
      );

      when(() => mockOAuthRepository.login()).thenAnswer((_) async => response);
      when(() => mockUserProfileRepository.saveUserProfile(any()))
          .thenThrow(Exception('Database error'));

      final expectation = [
        const EpsConnectionLoading(),
        isA<EpsConnectionError>().having((e) => e.message, 'message', contains('Database error')),
      ];

      expectLater(cubit.stream, emitsInOrder(expectation));

      await cubit.connect();
    });

  });
}
