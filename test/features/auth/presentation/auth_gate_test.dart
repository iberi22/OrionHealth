import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:local_auth/local_auth.dart' show BiometricType;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:orionhealth_health/features/auth/application/bloc/auth_cubit.dart';
import 'package:orionhealth_health/features/auth/application/bloc/auth_state.dart';
import 'package:orionhealth_health/features/auth/infrastructure/services/encryption_service.dart';
import 'package:orionhealth_health/features/auth/infrastructure/services/biometric_service.dart';
import 'package:orionhealth_health/features/auth/domain/repositories/auth_repository.dart';
import 'package:orionhealth_health/features/auth/domain/entities/auth_credentials.dart';
import 'package:orionhealth_health/features/auth/presentation/auth_gate.dart';
import 'package:orionhealth_health/features/auth/presentation/login_page.dart';
import 'package:orionhealth_health/features/auth/presentation/setup_pin_page.dart';
import 'package:orionhealth_health/features/user_profile/domain/repositories/user_profile_repository.dart';
import 'package:orionhealth_health/features/user_profile/domain/entities/user_profile.dart';
import 'package:orionhealth_health/l10n/app_localizations.dart';

import 'auth_gate_test.mocks.dart';

@GenerateMocks([UserProfileRepository, AuthRepository, EncryptionService, BiometricService])
void main() {
  final getIt = GetIt.instance;
  late MockUserProfileRepository mockUserProfileRepository;
  late MockAuthRepository mockAuthRepository;
  late MockEncryptionService mockEncryptionService;
  late MockBiometricService mockBiometricService;

  setUpAll(() {
    mockUserProfileRepository = MockUserProfileRepository();
    mockAuthRepository = MockAuthRepository();
    mockEncryptionService = MockEncryptionService();
    mockBiometricService = MockBiometricService();

    getIt.registerLazySingleton<UserProfileRepository>(() => mockUserProfileRepository);
    getIt.registerLazySingleton<AuthRepository>(() => mockAuthRepository);
    getIt.registerLazySingleton<EncryptionService>(() => mockEncryptionService);
    getIt.registerLazySingleton<BiometricService>(() => mockBiometricService);

    getIt.registerFactory<AuthCubit>(() => AuthCubit(
      mockAuthRepository,
      mockEncryptionService,
      mockBiometricService,
    ));
  });

  tearDownAll(() {
    getIt.reset();
  });

  setUp(() {
    reset(mockUserProfileRepository);
    reset(mockAuthRepository);
    reset(mockEncryptionService);
    reset(mockBiometricService);
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
      when(mockUserProfileRepository.getUserProfile()).thenAnswer((_) async => UserProfile(name: 'Test'));
      when(mockAuthRepository.getCredentials()).thenAnswer((_) async => Completer<AuthCredentials?>().future);

      await tester.pumpWidget(makeApp());
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('AuthNotSetup → SetupPinPage', (tester) async {
      when(mockUserProfileRepository.getUserProfile()).thenAnswer((_) async => UserProfile(name: 'Test'));
      when(mockAuthRepository.getCredentials()).thenAnswer((_) async => null);

      await tester.pumpWidget(makeApp());
      await tester.pumpAndSettle();

      expect(find.byType(SetupPinPage), findsOneWidget);
    });

    testWidgets('AuthUnauthenticated → LoginPage', (tester) async {
      when(mockUserProfileRepository.getUserProfile()).thenAnswer((_) async => UserProfile(name: 'Test'));
      final credentials = AuthCredentials()..hashedPin = 'hashed'..salt = 'salt';
      when(mockAuthRepository.getCredentials()).thenAnswer((_) async => credentials);

      await tester.pumpWidget(makeApp());
      await tester.pumpAndSettle();

      expect(find.byType(LoginPage), findsOneWidget);
    });
  });
}
