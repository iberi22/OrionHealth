import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:orionhealth_health/features/auth/presentation/login_page.dart';
import 'package:orionhealth_health/features/auth/presentation/setup_pin_page.dart';
import 'package:orionhealth_health/features/auth/presentation/pages/auth_methods_page.dart';
import 'package:orionhealth_health/features/auth/application/bloc/auth_cubit.dart';
import 'package:orionhealth_health/features/auth/application/bloc/auth_state.dart';
import 'package:orionhealth_health/features/health_sharing/application/sharing_cubit.dart';
import '../../../../core/golden_test_utils.dart';

class MockAuthCubit extends Mock implements AuthCubit {}
class MockSharingCubit extends Mock implements SharingCubit {}

void main() {
  late MockAuthCubit mockAuthCubit;
  late MockSharingCubit mockSharingCubit;

  setUp(() {
    mockAuthCubit = MockAuthCubit();
    mockSharingCubit = MockSharingCubit();

    final getIt = GetIt.instance;
    if (getIt.isRegistered<AuthCubit>()) {
      getIt.unregister<AuthCubit>();
    }
    if (getIt.isRegistered<SharingCubit>()) {
      getIt.unregister<SharingCubit>();
    }
    getIt.registerSingleton<AuthCubit>(mockAuthCubit);
    getIt.registerSingleton<SharingCubit>(mockSharingCubit);

    when(() => mockAuthCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockAuthCubit.loginWithBiometrics()).thenAnswer((_) async {});

    when(() => mockSharingCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockSharingCubit.state).thenReturn(SharingInitial());
  });

  tearDown(() async {
    await GetIt.instance.reset();
  });

  group('Auth Pages Golden Tests', () {
    testWidgets('LoginPage - Initial State', (tester) async {
      setupGoldenTest(tester);
      when(() => mockAuthCubit.state).thenReturn(const AuthInitial());

      await tester.pumpWidget(wrapWithMaterial(
        const LoginPage(),
        authCubit: mockAuthCubit,
      ));
      await tester.pump();

      await expectLater(
        find.byType(LoginPage),
        matchesGoldenFile("goldens/login_page_initial.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('LoginPage - Locked State', (tester) async {
      setupGoldenTest(tester);
      final lockoutUntil = DateTime(2026, 6, 15, 14, 30);
      when(() => mockAuthCubit.state).thenReturn(AuthLocked(lockoutUntil));

      await tester.pumpWidget(wrapWithMaterial(
        const LoginPage(),
        authCubit: mockAuthCubit,
      ));
      await tester.pump();

      await expectLater(
        find.byType(LoginPage),
        matchesGoldenFile("goldens/login_page_locked.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('SetupPinPage - Initial State', (tester) async {
      setupGoldenTest(tester);
      when(() => mockAuthCubit.state).thenReturn(const AuthInitial());

      await tester.pumpWidget(wrapWithMaterial(
        const SetupPinPage(),
        authCubit: mockAuthCubit,
      ));
      await tester.pump();

      await expectLater(
        find.byType(SetupPinPage),
        matchesGoldenFile("goldens/setup_pin_page_initial.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('AuthMethodsPage - Initial State', (tester) async {
      setupGoldenTest(tester);
      when(() => mockAuthCubit.state).thenReturn(const AuthInitial());

      await tester.pumpWidget(wrapWithMaterial(
        const AuthMethodsPage(),
        authCubit: mockAuthCubit,
      ));
      await tester.pump();

      await expectLater(
        find.byType(AuthMethodsPage),
        matchesGoldenFile("goldens/auth_methods_page_initial.png"),
      );
      resetGoldenTest(tester);
    });
  });
}
