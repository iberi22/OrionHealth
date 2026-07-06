import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/auth/application/bloc/auth_cubit.dart';
import 'package:orionhealth_health/features/auth/infrastructure/services/biometric_service.dart';
import 'package:orionhealth_health/features/auth/domain/repositories/auth_repository.dart';
import 'package:orionhealth_health/features/auth/domain/entities/auth_credentials.dart';
import 'package:orionhealth_health/features/auth/domain/entities/auth_credential.dart';
import 'package:orionhealth_health/features/auth/domain/usecases/login_usecase.dart';
import 'package:orionhealth_health/features/auth/domain/usecases/logout_usecase.dart';
import 'package:orionhealth_health/features/auth/domain/usecases/validate_session_usecase.dart';
import 'package:orionhealth_health/features/auth/domain/usecases/set_pin_usecase.dart';
import 'package:orionhealth_health/features/auth/presentation/auth_gate.dart';
import 'package:orionhealth_health/features/auth/presentation/login_page.dart';
import 'package:orionhealth_health/features/auth/presentation/setup_pin_page.dart';
import 'package:orionhealth_health/features/onboarding/presentation/pages/onboarding_main_page.dart';
import 'package:orionhealth_health/features/user_profile/domain/repositories/user_profile_repository.dart';
import 'package:orionhealth_health/features/user_profile/domain/entities/user_profile.dart';
import 'package:orionhealth_health/l10n/app_localizations.dart';

class MockUserProfileRepository extends Mock implements UserProfileRepository {}
class MockAuthRepository extends Mock implements AuthRepository {}
class MockBiometricService extends Mock implements BiometricService {}
class MockLoginUseCase extends Mock implements LoginUseCase {}
class MockLogoutUseCase extends Mock implements LogoutUseCase {}
class MockValidateSessionUseCase extends Mock implements ValidateSessionUseCase {}
class MockSetPinUseCase extends Mock implements SetPinUseCase {}

class FakeAuthCredential extends Fake implements AuthCredential {}

void main() {
  final getIt = GetIt.instance;
  late MockUserProfileRepository mockUserProfileRepository;
  late MockAuthRepository mockAuthRepository;
  late MockBiometricService mockBiometricService;
  late MockLoginUseCase mockLoginUseCase;
  late MockLogoutUseCase mockLogoutUseCase;
  late MockValidateSessionUseCase mockValidateSessionUseCase;
  late MockSetPinUseCase mockSetPinUseCase;

  setUpAll(() {
    registerFallbackValue(FakeAuthCredential());

    mockUserProfileRepository = MockUserProfileRepository();
    mockAuthRepository = MockAuthRepository();
    mockBiometricService = MockBiometricService();
    mockLoginUseCase = MockLoginUseCase();
    mockLogoutUseCase = MockLogoutUseCase();
    mockValidateSessionUseCase = MockValidateSessionUseCase();
    mockSetPinUseCase = MockSetPinUseCase();

    getIt.registerLazySingleton<UserProfileRepository>(() => mockUserProfileRepository);
    getIt.registerLazySingleton<AuthRepository>(() => mockAuthRepository);
    getIt.registerLazySingleton<BiometricService>(() => mockBiometricService);
    getIt.registerLazySingleton<LoginUseCase>(() => mockLoginUseCase);
    getIt.registerLazySingleton<LogoutUseCase>(() => mockLogoutUseCase);
    getIt.registerLazySingleton<ValidateSessionUseCase>(() => mockValidateSessionUseCase);
    getIt.registerLazySingleton<SetPinUseCase>(() => mockSetPinUseCase);

    getIt.registerFactory<AuthCubit>(() => AuthCubit(
      mockAuthRepository,
      mockBiometricService,
      mockLoginUseCase,
      mockLogoutUseCase,
      mockValidateSessionUseCase,
      mockSetPinUseCase,
    ));
  });

  tearDownAll(() {
    getIt.reset();
  });

  setUp(() {
    reset(mockUserProfileRepository);
    reset(mockAuthRepository);
    reset(mockBiometricService);
    reset(mockLoginUseCase);
    reset(mockLogoutUseCase);
    reset(mockValidateSessionUseCase);
    reset(mockSetPinUseCase);

    // Default stubs
    when(() => mockLoginUseCase(any())).thenAnswer((_) async => null);
    when(() => mockBiometricService.canCheckBiometrics()).thenAnswer((_) async => false);
  });

  Widget makeApp() {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const AuthGate(),
    );
  }

  group('AuthGate', () {
    testWidgets('AuthInitial → CircularProgressIndicator', (tester) async {
      when(() => mockUserProfileRepository.getUserProfile()).thenAnswer((_) async => UserProfile(name: 'Test'));
      when(() => mockValidateSessionUseCase()).thenAnswer((_) async => null);
      when(() => mockAuthRepository.getCredentials()).thenAnswer((_) async => Completer<AuthCredentials?>().future);

      await tester.pumpWidget(makeApp());
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('AuthNotSetup → SetupPinPage', (tester) async {
      when(() => mockUserProfileRepository.getUserProfile()).thenAnswer((_) async => UserProfile(name: 'Test'));
      when(() => mockValidateSessionUseCase()).thenAnswer((_) async => null);
      when(() => mockAuthRepository.getCredentials()).thenAnswer((_) async => null);

      await tester.pumpWidget(makeApp());
      await tester.pumpAndSettle();

      expect(find.byType(SetupPinPage), findsOneWidget);
    });

    testWidgets('AuthUnauthenticated → LoginPage', (tester) async {
      when(() => mockUserProfileRepository.getUserProfile()).thenAnswer((_) async => UserProfile(name: 'Test'));
      when(() => mockValidateSessionUseCase()).thenAnswer((_) async => null);
      final credentials = AuthCredentials()..hashedPin = 'hashed'..salt = 'salt';
      when(() => mockAuthRepository.getCredentials()).thenAnswer((_) async => credentials);

      await tester.pumpWidget(makeApp());
      await tester.pumpAndSettle();

      expect(find.byType(LoginPage), findsOneWidget);
    });

    testWidgets('UserProfile null → OnboardingMainPage', (tester) async {
      when(() => mockUserProfileRepository.getUserProfile()).thenAnswer((_) async => null);

      await tester.pumpWidget(makeApp());
      await tester.pumpAndSettle();

      expect(find.byType(OnboardingMainPage), findsOneWidget);
    });
  });
}
