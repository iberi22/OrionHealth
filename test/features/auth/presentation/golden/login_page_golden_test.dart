import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/auth/application/bloc/auth_cubit.dart';
import 'package:orionhealth_health/features/auth/application/bloc/auth_state.dart';
import 'package:orionhealth_health/features/auth/presentation/login_page.dart';
import '../../../../core/golden_test_utils.dart';

class MockAuthCubit extends Mock implements AuthCubit {}

void main() {
  late MockAuthCubit mockAuthCubit;

  setUp(() {
    mockAuthCubit = MockAuthCubit();
    when(() => mockAuthCubit.state).thenReturn(const AuthInitial());
    when(() => mockAuthCubit.loginWithBiometrics()).thenAnswer((_) async {});
    when(() => mockAuthCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockAuthCubit.close()).thenAnswer((_) async {});
  });

  testWidgets('Login Page Golden Screenshot', (WidgetTester tester) async {
    setupGoldenTest(tester);

    await tester.pumpWidget(
      wrapWithMaterial(
        BlocProvider<AuthCubit>.value(
          value: mockAuthCubit,
          child: const LoginPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await expectLater(
      find.byType(LoginPage),
      matchesGoldenFile("goldens/login_page.png"),
    );

    resetGoldenTest(tester);
  });

  testWidgets('Login Page Locked State Golden Screenshot', (WidgetTester tester) async {
    setupGoldenTest(tester);

    final lockoutUntil = DateTime(2026, 6, 15, 14, 30);
    when(() => mockAuthCubit.state).thenReturn(AuthLocked(lockoutUntil));

    await tester.pumpWidget(
      wrapWithMaterial(
        BlocProvider<AuthCubit>.value(
          value: mockAuthCubit,
          child: const LoginPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await expectLater(
      find.byType(LoginPage),
      matchesGoldenFile("goldens/login_page_locked.png"),
    );

    resetGoldenTest(tester);
  });
}
