import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/auth/application/bloc/auth_cubit.dart';
import 'package:orionhealth_health/features/auth/application/bloc/auth_state.dart';
import 'package:orionhealth_health/features/auth/presentation/login_page.dart';
import 'package:orionhealth_health/l10n/app_localizations.dart';

class MockAuthCubit extends Mock implements AuthCubit {}

void main() {
  late MockAuthCubit mockCubit;

  setUp(() {
    mockCubit = MockAuthCubit();
    when(() => mockCubit.state).thenReturn(const AuthUnauthenticated());
    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockCubit.loginWithBiometrics()).thenAnswer((_) async {});
    when(() => mockCubit.close()).thenAnswer((_) async {});
  });

  Widget createWidgetUnderTest() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>.value(value: mockCubit),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: LoginPage(),
      ),
    );
  }

  group('LoginPage', () {
    testWidgets('renders pin input and login button', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Entrar'), findsOneWidget);
    });

    testWidgets('shows error message from state', (tester) async {
      when(() => mockCubit.state).thenReturn(const AuthUnauthenticated(errorMessage: 'Invalid pin'));

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Invalid pin'), findsOneWidget);
    });

    testWidgets('calls loginWithPin when form submitted', (tester) async {
      when(() => mockCubit.loginWithPin(any())).thenAnswer((_) async {});

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(find.byType(TextField), '1234');
      await tester.tap(find.text('Entrar'));
      await tester.pump();

      verify(() => mockCubit.loginWithPin('1234')).called(1);
    });

    testWidgets('calls loginWithBiometrics when fingerprint icon tapped', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.byIcon(Icons.fingerprint));
      await tester.pump();

      verify(() => mockCubit.loginWithBiometrics()).called(2); // One in initState, one on tap
    });

    testWidgets('shows lockout screen when state is AuthLocked', (tester) async {
      final lockoutTime = DateTime.now().add(const Duration(minutes: 5));
      when(() => mockCubit.state).thenReturn(AuthLocked(lockoutTime));

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Acceso Bloqueado'), findsOneWidget);
      expect(find.byIcon(Icons.lock), findsOneWidget);
    });
  });
}
