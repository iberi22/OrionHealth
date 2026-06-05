import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth/local_auth.dart' show BiometricType;
import 'package:orionhealth_health/features/auth/application/bloc/auth_cubit.dart';
import 'package:orionhealth_health/features/auth/application/bloc/auth_state.dart';
import 'package:orionhealth_health/features/auth/infrastructure/services/encryption_service.dart';
import 'package:orionhealth_health/features/auth/infrastructure/services/biometric_service.dart';
import 'package:orionhealth_health/features/auth/domain/repositories/auth_repository.dart';
import 'package:orionhealth_health/features/auth/domain/entities/auth_credentials.dart';
import 'package:orionhealth_health/features/auth/presentation/auth_gate.dart';
import 'package:orionhealth_health/features/auth/presentation/login_page.dart';
import 'package:orionhealth_health/features/auth/presentation/setup_pin_page.dart';
import 'package:orionhealth_health/l10n/app_localizations.dart';

// ═══════════════════════════════════════════
// FAKE SERVICES
// ═══════════════════════════════════════════

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<AuthCredentials?> getCredentials() async => null;
  @override
  Future<void> saveCredentials(AuthCredentials credentials) async {}
  @override
  Future<bool> hasPinSet() async => false;
  @override
  Future<bool> isBiometricsEnabled() async => false;
  @override
  Future<void> deleteCredentials() async {}
}

class _FakeEncryptionService implements EncryptionService {
  @override
  Future<String> hashPin(String pin, String salt) async => '';
  @override
  Future<bool> verifyPin(String pin, String storedHash, String salt) async => true;
  @override
  Future<String> generatePinSalt() async => '';
  @override
  Future<void> initialize() async {}
  @override
  Future<Uint8List> encryptBytes(Uint8List plainBytes) async => plainBytes;
  @override
  Future<Uint8List> decryptBytes(Uint8List encryptedBytes) async => encryptedBytes;
  @override
  Future<dynamic> encrypt(String data, [String? key]) async => data;
  @override
  Future<String> decrypt(String encryptedData, String key) async => encryptedData;
}

class _FakeBiometricService implements BiometricService {
  @override
  Future<bool> isBiometricAvailable() async => true;
  @override
  Future<List<BiometricType>> getAvailableBiometrics() async => [];
  @override
  Future<bool> authenticate({String localizedReason = ''}) async => true;
}

class _FakeAuthCubit extends AuthCubit {
  _FakeAuthCubit()
      : super(
          _FakeAuthRepository(),
          _FakeEncryptionService(),
          _FakeBiometricService(),
        );
  void setState(AuthState newState) => emit(newState);
}

Widget makeApp(_FakeAuthCubit cubit) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: BlocProvider<AuthCubit>(
      create: (_) => cubit,
      child: const AuthenticatedGate(),
    ),
  );
}

// ═══════════════════════════════════════════
// AUTH GATE TESTS
// ═══════════════════════════════════════════
// Tests each auth state → correct page rendering.
// AuthAuthenticated → MainNavigationPage is skipped because
// MainNavigationPage depends on main.dart's full widget tree
// (GetIt-registered services, nested providers, etc.).
// This keeps the test isolated to auth gate logic.
// ═══════════════════════════════════════════

void main() {
  group('AuthenticatedGate', () {
    testWidgets('AuthInitial → CircularProgressIndicator', (tester) async {
      final cubit = _FakeAuthCubit();
      await tester.pumpWidget(makeApp(cubit));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('AuthLoading → CircularProgressIndicator', (tester) async {
      final cubit = _FakeAuthCubit();
      cubit.setState(const AuthLoading());
      await tester.pumpWidget(makeApp(cubit));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('AuthNotSetup → SetupPinPage', (tester) async {
      final cubit = _FakeAuthCubit();
      cubit.setState(const AuthNotSetup());
      await tester.pumpWidget(makeApp(cubit));
      await tester.pump();
      expect(find.byType(SetupPinPage), findsOneWidget);
    });

    testWidgets('AuthLocked → LoginPage', (tester) async {
      final cubit = _FakeAuthCubit();
      cubit.setState(AuthLocked(DateTime(2026, 6, 1, 12, 0)));
      await tester.pumpWidget(makeApp(cubit));
      await tester.pump();
      expect(find.byType(LoginPage), findsOneWidget);
    });

    testWidgets('AuthUnauthenticated → LoginPage', (tester) async {
      final cubit = _FakeAuthCubit();
      cubit.setState(const AuthUnauthenticated());
      await tester.pumpWidget(makeApp(cubit));
      await tester.pump();
      expect(find.byType(LoginPage), findsOneWidget);
    });
  });
}
