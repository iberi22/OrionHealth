import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/auth/application/auth_cubit.dart';
import 'package:orionhealth_health/features/auth/application/auth_state.dart';
import 'package:orionhealth_health/features/auth/presentation/pages/login_page.dart';
import 'package:orionhealth_health/l10n/app_localizations.dart';

class MockAuthCubit extends Mock implements AuthCubit {}

void main() {
  late MockAuthCubit mockAuthCubit;

  setUp(() {
    mockAuthCubit = MockAuthCubit();
    when(() => mockAuthCubit.state).thenReturn(const AuthState());
    when(() => mockAuthCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockAuthCubit.close()).thenAnswer((_) async {});
  });

  Widget createWidgetUnderTest() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>.value(value: mockAuthCubit),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: LoginPage(),
      ),
    );
  }

  group('LoginPage', () {
    testWidgets('shows PIN setup UI when isPinSet is false', (tester) async {
      when(() => mockAuthCubit.state).thenReturn(const AuthState(isPinSet: false));

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Set up your PIN'), findsOneWidget);
      expect(find.text('New PIN'), findsOneWidget);
      expect(find.text('PIN must be 4-6 digits'), findsOneWidget);
    });

    testWidgets('calls authCubit.setPin when Set PIN button is pressed with valid PIN', (tester) async {
      when(() => mockAuthCubit.state).thenReturn(const AuthState(isPinSet: false));
      when(() => mockAuthCubit.setPin(any())).thenAnswer((_) async {});

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(find.byType(TextField), '1234');
      await tester.tap(find.text('Set PIN'));
      await tester.pump();

      verify(() => mockAuthCubit.setPin('1234')).called(1);
    });

    testWidgets('shows Login form UI when isPinSet is true', (tester) async {
      when(() => mockAuthCubit.state).thenReturn(const AuthState(isPinSet: true));

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Enter PIN'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
    });

    testWidgets('calls authCubit.submitPin when Login button is pressed with valid PIN', (tester) async {
      when(() => mockAuthCubit.state).thenReturn(const AuthState(isPinSet: true));
      when(() => mockAuthCubit.submitPin(any())).thenAnswer((_) async {});

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(find.byType(TextField), '1234');
      await tester.tap(find.text('Login'));
      await tester.pump();

      verify(() => mockAuthCubit.submitPin('1234')).called(1);
    });

    testWidgets('shows Use Biometric button when isBiometricAvailable is true and calls verifyBiometric when tapped', (tester) async {
      when(() => mockAuthCubit.state).thenReturn(const AuthState(isPinSet: true, isBiometricAvailable: true));
      when(() => mockAuthCubit.verifyBiometric()).thenAnswer((_) async {});

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Use Biometric'), findsOneWidget);
      await tester.tap(find.text('Use Biometric'));
      await tester.pump();

      verify(() => mockAuthCubit.verifyBiometric()).called(1);
    });

    testWidgets('shows SnackBar with error message when state status is AuthStatus.error', (tester) async {
      final states = [
        const AuthState(isPinSet: true),
        const AuthState(status: AuthStatus.error, error: 'Authentication Failed', isPinSet: true),
      ];
      when(() => mockAuthCubit.state).thenReturn(states[0]);
      when(() => mockAuthCubit.stream).thenAnswer((_) => Stream.fromIterable(states));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(); // Trigger listener

      expect(find.text('Authentication Failed'), findsOneWidget);
    });

    group('Accessibility', () {
      testWidgets('should have a centered OrionHealth text', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());
        expect(find.text('OrionHealth'), findsOneWidget);
      });

      testWidgets('should show circular progress indicator when loading', (tester) async {
        when(() => mockAuthCubit.state).thenReturn(const AuthState(status: AuthStatus.loading));
        await tester.pumpWidget(createWidgetUnderTest());
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });
    });
  });
}
