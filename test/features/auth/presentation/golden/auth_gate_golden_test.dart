import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/auth/presentation/auth_gate.dart';
import 'package:orionhealth_health/features/user_profile/domain/repositories/user_profile_repository.dart';
import 'package:orionhealth_health/features/user_profile/domain/entities/user_profile.dart';
import 'package:orionhealth_health/features/auth/application/bloc/auth_cubit.dart';
import 'package:orionhealth_health/features/auth/infrastructure/services/biometric_service.dart';
import 'package:orionhealth_health/features/auth/domain/repositories/auth_repository.dart';
import 'package:orionhealth_health/features/auth/domain/usecases/login_usecase.dart';
import 'package:orionhealth_health/features/auth/domain/usecases/logout_usecase.dart';
import 'package:orionhealth_health/features/auth/domain/usecases/validate_session_usecase.dart';
import 'package:orionhealth_health/features/auth/domain/usecases/set_pin_usecase.dart';
import 'package:orionhealth_health/features/auth/domain/usecases/check_session_timeout.dart';
import '../../../../core/golden_test_utils.dart';

class MockUserProfileRepository extends Mock implements UserProfileRepository {}
class MockAuthRepository extends Mock implements AuthRepository {}
class MockBiometricService extends Mock implements BiometricService {}
class MockLoginUseCase extends Mock implements LoginUseCase {}
class MockLogoutUseCase extends Mock implements LogoutUseCase {}
class MockValidateSessionUseCase extends Mock implements ValidateSessionUseCase {}
class MockSetPinUseCase extends Mock implements SetPinUseCase {}
class MockCheckSessionTimeoutUseCase extends Mock implements CheckSessionTimeoutUseCase {}

void main() {
  final getIt = GetIt.instance;
  late MockUserProfileRepository mockUserProfileRepository;

  setUpAll(() {
    mockUserProfileRepository = MockUserProfileRepository();
    getIt.registerLazySingleton<UserProfileRepository>(() => mockUserProfileRepository);

    // Register other dependencies for AuthGate (even if not used in loading test)
    getIt.registerLazySingleton<AuthRepository>(() => MockAuthRepository());
    getIt.registerLazySingleton<BiometricService>(() => MockBiometricService());
    getIt.registerLazySingleton<LoginUseCase>(() => MockLoginUseCase());
    getIt.registerLazySingleton<LogoutUseCase>(() => MockLogoutUseCase());
    getIt.registerLazySingleton<ValidateSessionUseCase>(() => MockValidateSessionUseCase());
    getIt.registerLazySingleton<SetPinUseCase>(() => MockSetPinUseCase());
    getIt.registerLazySingleton<CheckSessionTimeoutUseCase>(() => MockCheckSessionTimeoutUseCase());

    getIt.registerFactory<AuthCubit>(() => AuthCubit(
      getIt<AuthRepository>(),
      getIt<BiometricService>(),
      getIt<LoginUseCase>(),
      getIt<LogoutUseCase>(),
      getIt<ValidateSessionUseCase>(),
      getIt<SetPinUseCase>(),
      getIt<CheckSessionTimeoutUseCase>(),
    ));
  });

  tearDownAll(() {
    getIt.reset();
  });

  group('AuthGate Golden Tests', () {
    testWidgets('AuthGate - loading state (no user profile yet)', (tester) async {
      setupGoldenTest(tester);

      // Force FutureBuilder to stay in waiting state by providing a future that never completes during the pump
      final completer = Completer<UserProfile?>();
      when(() => mockUserProfileRepository.getUserProfile()).thenAnswer((_) => completer.future);

      await tester.pumpWidget(wrapWithMaterial(const AuthGate()));
      // No pump() or pumpAndSettle() to keep it in loading state

      await expectLater(
        find.byType(AuthGate),
        matchesGoldenFile('goldens/auth_gate_loading.png'),
      );
      resetGoldenTest(tester);
    });
  });
}
