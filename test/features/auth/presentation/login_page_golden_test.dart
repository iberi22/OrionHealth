import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/auth/application/bloc/auth_cubit.dart';
import 'package:orionhealth_health/features/auth/application/bloc/auth_state.dart';
import 'package:orionhealth_health/features/auth/presentation/login_page.dart';
import 'package:orionhealth_health/l10n/app_localizations.dart';
import 'package:orionhealth_health/core/theme/app_theme.dart';

class MockAuthCubit extends Mock implements AuthCubit {}

void main() {
  late MockAuthCubit mockAuthCubit;

  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = true;
    mockAuthCubit = MockAuthCubit();
    when(() => mockAuthCubit.state).thenReturn(const AuthInitial());
    when(() => mockAuthCubit.loginWithBiometrics()).thenAnswer((_) async {});
    when(() => mockAuthCubit.stream).thenAnswer((_) => const Stream.empty());
  });

  testWidgets('Login Page Golden Screenshot', (WidgetTester tester) async {
    // Set a fixed size for the screenshot
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('es'),
        home: BlocProvider<AuthCubit>.value(
          value: mockAuthCubit,
          child: const LoginPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await expectLater(
      find.byType(LoginPage),
      matchesGoldenFile('../../../goldens/login_page.png'),
    );

    // Reset view
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });

  testWidgets('Login Page Locked State Golden Screenshot', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;

    final lockoutUntil = DateTime(2026, 6, 15, 14, 30);
    when(() => mockAuthCubit.state).thenReturn(AuthLocked(lockoutUntil));

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('es'),
        home: BlocProvider<AuthCubit>.value(
          value: mockAuthCubit,
          child: const LoginPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await expectLater(
      find.byType(LoginPage),
      matchesGoldenFile('../../../goldens/login_page_locked.png'),
    );

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
