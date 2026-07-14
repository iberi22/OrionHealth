import 'package:flutter/material.dart';
import '../../../../core/di/injection.dart';
import '../../../user_profile/domain/entities/user_profile.dart';
import '../../../user_profile/domain/repositories/user_profile_repository.dart';
import '../../../../core/theme/cyber_theme.dart';
import 'onboarding_welcome_page.dart';
import 'onboarding_profile_page.dart';
import 'onboarding_vitals_page.dart';
import 'onboarding_allergies_page.dart';
import 'onboarding_complete_page.dart';

/// Onboarding Main Page
///
/// Orchestrates the multi-step onboarding flow:
/// 0. Welcome (3 slides + EPS connection option)
/// 1. Profile (name, birthDate, sex, bloodType)
/// 2. Vitals (weight, height, BP, heart rate)
/// 3. Allergies
/// 4. Complete
///
/// EPS Integration:
/// - Welcome screen has "Conectar mi EPS" that opens the full EPS portal flow
/// - When EPS data is received, it auto-fills the profile step
/// - A green banner shows "Datos importados desde [EPS] ✓" on the profile page
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

  // EPS imported data tracking
  bool _epsDataImported = false;
  String? _epsProviderName;

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

  /// Called when health/fitness data sources are connected.
  void _onHealthSourcesConnected(Set<String> sourceIds) {
    setState(() {
      _onboardingData['healthSources'] = sourceIds.toList();
    });
  }

  /// Called when EPS data is received from the Welcome page EPS flow.
  /// This auto-fills the onboarding data map with EPS extracted fields.
  void _onEpsDataReceived(Map<String, dynamic> epsData) {
    setState(() {
      _epsDataImported = true;
      _epsProviderName = (epsData['epsProviderName'] ?? epsData['epsProviderId']) as String?;

      // Map EPS fields to onboarding fields
      if (epsData['name'] != null && epsData['name'].toString().isNotEmpty) {
        _onboardingData['name'] = epsData['name'];
      }
      if (epsData['documentId'] != null && epsData['documentId'].toString().isNotEmpty) {
        _onboardingData['documentId'] = epsData['documentId'];
      }
      if (epsData['birthDate'] != null && epsData['birthDate'].toString().isNotEmpty) {
        _onboardingData['birthDate'] = epsData['birthDate'];
      }
      if (epsData['sex'] != null && epsData['sex'].toString().isNotEmpty) {
        _onboardingData['sex'] = _normalizeSex(epsData['sex']);
      }
      if (epsData['affiliationType'] != null && epsData['affiliationType'].toString().isNotEmpty) {
        _onboardingData['affiliationType'] = epsData['affiliationType'];
      }
      if (epsData['conditions'] is List && (epsData['conditions'] as List).isNotEmpty) {
        // Store conditions — could be shown in a future "Medical History" step
        _onboardingData['conditions'] = epsData['conditions'];
      }
      if (epsData['medications'] is List && (epsData['medications'] as List).isNotEmpty) {
        _onboardingData['medications'] = epsData['medications'];
      }
      if (epsData['allergies'] is List && (epsData['allergies'] as List).isNotEmpty) {
        _onboardingData['allergies'] = epsData['allergies'];
      }

      // Also store EPS metadata
      _onboardingData['epsConnected'] = true;
      _onboardingData['epsProviderId'] = epsData['epsProviderId'];
      _onboardingData['epsProviderName'] = epsData['epsProviderName'];
    });

    // Show a snackbar confirmation
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✅ Datos importados desde $_epsProviderName',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: CyberTheme.success ?? Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  String _normalizeSex(dynamic sex) {
    final s = sex.toString().toLowerCase().trim();
    if (s == 'm' || s == 'male' || s == 'masculino' || s == 'hombre' || s == 'varon') return 'male';
    if (s == 'f' || s == 'female' || s == 'femenino' || s == 'mujer') return 'female';
    return sex.toString();
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

    // Standard fields
    profile.name = _onboardingData['name'];
    profile.birthDate = _onboardingData['birthDate'];
    profile.sex = _onboardingData['sex'];
    profile.bloodType = _onboardingData['bloodType'];

    // Vitals
    profile.weight = _onboardingData['weight'];
    profile.height = _onboardingData['height'];
    profile.systolicBP = _onboardingData['systolicBP'];
    profile.diastolicBP = _onboardingData['diastolicBP'];
    profile.heartRate = _onboardingData['heartRate'];

    // Allergies
    profile.allergyName = _onboardingData['allergyName'];
    profile.allergySeverity = _onboardingData['allergySeverity'];
    profile.allergyNotes = _onboardingData['allergyNotes'];

    // EPS connection data
    if (_onboardingData['epsConnected'] == true) {
      profile.isEpsConnected = true;
      profile.epsPatientId = _onboardingData['documentId'] as String?;
      // Could also store: affiliationType, conditions, medications
    }

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
            // Step 0: Welcome + EPS connection
            OnboardingWelcomePage(
              onNext: () => _nextStep({}),
              onEpsDataReceived: _onEpsDataReceived,
              onHealthSourcesConnected: _onHealthSourcesConnected,
            ),
            // Step 1: Profile (auto-filled from EPS if available)
            OnboardingProfilePage(
              initialData: _onboardingData,
              epsProviderName: _epsProviderName,
              onNext: _nextStep,
            ),
            // Step 2: Vitals
            OnboardingVitalsPage(
              initialData: _onboardingData,
              onNext: _nextStep,
            ),
            // Step 3: Allergies
            OnboardingAllergiesPage(
              initialData: _onboardingData,
              onNext: _nextStep,
            ),
            // Step 4: Complete
            OnboardingCompletePage(onComplete: _completeOnboarding),
          ],
        ),
      ),
    );
  }
}
