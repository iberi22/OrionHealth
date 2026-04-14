import 'package:flutter/material.dart';
import '../../../core/di/injection.dart';
import '../../user_profile/domain/repositories/user_profile_repository.dart';
import '../../onboarding/presentation/pages/onboarding_main_page.dart';
import '../../../main.dart'; // To access MainNavigationPage

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
          return const OnboardingMainPage();
        } else {
          return const MainNavigationPage();
        }
      },
    );
  }
}
