import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection.dart';
import '../../user_profile/domain/repositories/user_profile_repository.dart';
import '../../onboarding/presentation/pages/onboarding_main_page.dart';
import '../../home/presentation/pages/main_navigation_page.dart';
import '../application/bloc/auth_cubit.dart';
import '../application/bloc/auth_state.dart';
import 'login_page.dart';
import 'setup_pin_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getIt<UserProfileRepository>().getUserProfile(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final userProfile = snapshot.data;
        if (userProfile == null) {
          // No user profile exists — go to onboarding
          return OnboardingMainPage(
            onFinish: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const MainNavigationPage()),
              );
            },
          );
        }

        // User profile exists — validate actual authentication state
        // via AuthCubit, not just UI state
        return BlocProvider<AuthCubit>(
          create: (_) => getIt<AuthCubit>()..checkStatus(),
          child: const AuthenticatedGate(),
        );
      },
    );
  }
}

/// Validates actual auth state before granting access to the main app.
/// Uses AuthCubit to check pin/biometric authentication, not just UI state.
class AuthenticatedGate extends StatelessWidget {
  const AuthenticatedGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        switch (state) {
          case AuthInitial():
          case AuthLoading():
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );

          case AuthNotSetup():
            // pin has not been set up yet — prompt user to create one
            return const SetupPinPage();

          case AuthLocked():
            return const LoginPage();

          case AuthUnauthenticated():
            // User has pin/biometric set but is not authenticated
            return const LoginPage();

          case AuthAuthenticated():
            // Properly authenticated via pin or biometrics — grant access
            return const MainNavigationPage();
        }
      },
    );
  }
}
