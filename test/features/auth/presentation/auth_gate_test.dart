import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:orionhealth_health/main.dart';
import 'package:orionhealth_health/features/auth/application/bloc/auth_cubit.dart';
import 'package:orionhealth_health/features/auth/application/bloc/auth_state.dart';
import 'package:orionhealth_health/features/auth/presentation/auth_gate.dart';
import 'package:orionhealth_health/features/auth/presentation/login_page.dart';
import 'package:orionhealth_health/features/auth/presentation/setup_pin_page.dart';

// Mock AuthCubit for testing
class MockAuthCubit extends Mock implements AuthCubit {}

void main() {
  late MockAuthCubit mockAuthCubit;

  setUp(() {
    mockAuthCubit = MockAuthCubit();
  });

  tearDown(() {
    mockAuthCubit.close();
  });

  /// Helper to build the widget under test with a mocked AuthCubit
  Widget buildTestWidget(AuthState state) {
    when(mockAuthCubit.stream).thenAnswer((_) => Stream.value(state));
    when(mockAuthCubit.state).thenReturn(state);

    return MaterialApp(
      home: BlocProvider<AuthCubit>(
        create: (_) => mockAuthCubit,
        child: const AuthenticatedGate(),
      ),
    );
  }

  group('AuthenticatedGate', () {
    testWidgets('shows loading indicator when state is AuthInitial',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(const AuthInitial()));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(MainNavigationPage), findsNothing);
    });

    testWidgets('shows loading indicator when state is AuthLoading',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(const AuthLoading()));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(MainNavigationPage), findsNothing);
    });

    testWidgets('shows SetupPinPage when PIN is not set (AuthNotSetup)',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(const AuthNotSetup()));
      await tester.pump();

      expect(find.byType(SetupPinPage), findsOneWidget);
      expect(find.byType(MainNavigationPage), findsNothing);
    });

    testWidgets('shows LoginPage when state is AuthLocked', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(const AuthLocked(DateTime(2026, 6, 1, 12, 0))),
      );
      await tester.pump();

      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.byType(MainNavigationPage), findsNothing);
    });

    testWidgets('shows LoginPage when state is AuthUnauthenticated',
        (tester) async {
      await tester.pumpWidget(
        buildTestWidget(const AuthUnauthenticated()),
      );
      await tester.pump();

      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.byType(MainNavigationPage), findsNothing);
    });

    testWidgets('shows MainNavigationPage when state is AuthAuthenticated',
        (tester) async {
      when(mockAuthCubit.state).thenReturn(
        const AuthAuthenticated(DateTime(2026, 6, 1, 12, 15)),
      );

      await tester.pumpWidget(
        buildTestWidget(const AuthAuthenticated(DateTime(2026, 6, 1, 12, 15))),
      );
      await tester.pump();

      expect(find.byType(MainNavigationPage), findsOneWidget);
      expect(find.byType(LoginPage), findsNothing);
    });
  });

  group('AuthGate', () {
    testWidgets(
        'shows LoginPage for unauthenticated user with existing profile',
        (tester) async {
      when(mockAuthCubit.stream).thenAnswer(
        (_) => Stream.value(const AuthUnauthenticated()),
      );
      when(mockAuthCubit.state).thenReturn(const AuthUnauthenticated());

      await tester.pumpWidget(MaterialApp(
        home: BlocProvider<AuthCubit>(
          create: (_) => mockAuthCubit,
          child: const AuthenticatedGate(),
        ),
      ));
      await tester.pump();

      // Should show login page for unauthenticated users
      expect(find.byType(LoginPage), findsOneWidget);
    });

    testWidgets(
        'shows MainNavigationPage for authenticated users with existing profile',
        (tester) async {
      when(mockAuthCubit.stream).thenAnswer(
        (_) => Stream.value(
          const AuthAuthenticated(DateTime(2026, 6, 1, 12, 15)),
        ),
      );
      when(mockAuthCubit.state).thenReturn(
        const AuthAuthenticated(DateTime(2026, 6, 1, 12, 15)),
      );

      await tester.pumpWidget(MaterialApp(
        home: BlocProvider<AuthCubit>(
          create: (_) => mockAuthCubit,
          child: const AuthenticatedGate(),
        ),
      ));
      await tester.pump();

      // Should only show the main page after authentication
      expect(find.byType(MainNavigationPage), findsOneWidget);
      expect(find.byType(LoginPage), findsNothing);
      expect(find.byType(SetupPinPage), findsNothing);
    });

    testWidgets('shows SetupPinPage when auth not set up', (tester) async {
      when(mockAuthCubit.stream).thenAnswer(
        (_) => Stream.value(const AuthNotSetup()),
      );
      when(mockAuthCubit.state).thenReturn(const AuthNotSetup());

      await tester.pumpWidget(MaterialApp(
        home: BlocProvider<AuthCubit>(
          create: (_) => mockAuthCubit,
          child: const AuthenticatedGate(),
        ),
      ));
      await tester.pump();

      // Should show PIN setup page when PIN hasn't been set
      expect(find.byType(SetupPinPage), findsOneWidget);
      expect(find.byType(MainNavigationPage), findsNothing);
    });

    testWidgets('shows lock screen when account is locked', (tester) async {
      when(mockAuthCubit.stream).thenAnswer(
        (_) => Stream.value(
          const AuthLocked(DateTime(2026, 6, 1, 12, 30)),
        ),
      );
      when(mockAuthCubit.state).thenReturn(
        const AuthLocked(DateTime(2026, 6, 1, 12, 30)),
      );

      await tester.pumpWidget(MaterialApp(
        home: BlocProvider<AuthCubit>(
          create: (_) => mockAuthCubit,
          child: const AuthenticatedGate(),
        ),
      ));
      await tester.pump();

      // Should show login page (which renders lock screen)
      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.byType(MainNavigationPage), findsNothing);
    });

    testWidgets('prevents direct navigation bypass by checking auth state',
        (tester) async {
      // Test: if user tries to navigate past auth without authentication,
      // they should always see a login/setup/locked screen
      final bypassStates = <AuthState>[
        const AuthInitial(),
        const AuthLoading(),
        const AuthNotSetup(),
        const AuthUnauthenticated(),
        const AuthLocked(DateTime(2026, 6, 1, 12, 0)),
      ];

      for (final state in bypassStates) {
        when(mockAuthCubit.stream).thenAnswer((_) => Stream.value(state));
        when(mockAuthCubit.state).thenReturn(state);

        await tester.pumpWidget(MaterialApp(
          home: BlocProvider<AuthCubit>(
            create: (_) => mockAuthCubit,
            child: const AuthenticatedGate(),
          ),
        ));
        await tester.pump();

        // MainNavigationPage should NEVER appear for any non-authenticated state
        expect(
          find.byType(MainNavigationPage),
          findsNothing,
          reason:
              'Bypass attempt failed: state $state should NOT show MainNavigationPage',
        );
      }
    });
  });
}
