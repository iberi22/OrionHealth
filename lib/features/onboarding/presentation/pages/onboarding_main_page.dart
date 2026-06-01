import 'package:flutter/material.dart';
import '../../../../core/di/injection.dart';
import '../../../user_profile/domain/entities/user_profile.dart';
import '../../../user_profile/domain/repositories/user_profile_repository.dart';
import 'onboarding_welcome_page.dart';
import 'onboarding_profile_page.dart';
import 'onboarding_vitals_page.dart';
import 'onboarding_allergies_page.dart';
import 'onboarding_complete_page.dart';

class OnboardingMainPage extends StatefulWidget {
  final VoidCallback onFinish;

  const OnboardingMainPage({super.key, required this.onFinish});

  @override
  State<OnboardingMainPage> createState() => _OnboardingMainPageState();
}

class _OnboardingMainPageState extends State<OnboardingMainPage> {
  final PageController _pageController = PageController();
  final Map<String, dynamic> _onboardingData = {};
  int _currentStep = 0;

  void _nextStep(Map<String, dynamic> data) {
    setState(() {
      _onboardingData.addAll(data);
      _currentStep++;
    });
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeOnboarding() async {
    final repository = getIt<UserProfileRepository>();

    // Create or update UserProfile
    final existingProfile = await repository.getUserProfile();
    final profile = existingProfile ?? UserProfile();

    profile.name = _onboardingData['name'];
    profile.birthDate = _onboardingData['birthDate'];
    profile.sex = _onboardingData['sex'];
    profile.bloodType = _onboardingData['bloodType'];

    profile.weight = _onboardingData['weight'];
    profile.height = _onboardingData['height'];
    profile.systolicBP = _onboardingData['systolicBP'];
    profile.diastolicBP = _onboardingData['diastolicBP'];
    profile.heartRate = _onboardingData['heartRate'];

    profile.allergyName = _onboardingData['allergyName'];
    profile.allergySeverity = _onboardingData['allergySeverity'];
    profile.allergyNotes = _onboardingData['allergyNotes'];

    profile.onboardingCompleted = true;

    await repository.saveUserProfile(profile);
    widget.onFinish();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _currentStep > 0 && _currentStep < 4
          ? AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _prevStep,
              ),
              title: Text('Step ${_currentStep + 1} of 5'),
            )
          : null,
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            OnboardingWelcomePage(onNext: () => _nextStep({})),
            OnboardingProfilePage(
              initialData: _onboardingData,
              onNext: _nextStep,
            ),
            OnboardingVitalsPage(
              initialData: _onboardingData,
              onNext: _nextStep,
            ),
            OnboardingAllergiesPage(
              initialData: _onboardingData,
              onNext: _nextStep,
            ),
            OnboardingCompletePage(onComplete: _completeOnboarding),
          ],
        ),
      ),
    );
  }
}
