import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/entities/user_profile.dart';
import '../../user_profile/domain/entities/user_profile.dart' as up;
import '../../user_profile/domain/repositories/user_profile_repository.dart';

part 'onboarding_state.dart';

@injectable
class OnboardingCubit extends Cubit<OnboardingState> {
  final UserProfileRepository _userProfileRepository;
  final OnboardingUserProfile _profile = OnboardingUserProfile();
  int _currentStep = 0;

  OnboardingCubit(this._userProfileRepository) : super(const OnboardingInitial());

  int get currentStep => _currentStep;

  void startOnboarding() {
    _currentStep = 0;
    emit(OnboardingStepChanged(step: 0));
  }

  void nextStep() {
    if (_currentStep < 6) {
      _currentStep++;
      emit(OnboardingStepChanged(step: _currentStep));
    }
  }

  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      emit(OnboardingStepChanged(step: _currentStep));
    }
  }

  void goToStep(int step) {
    if (step >= 0 && step <= 6) {
      _currentStep = step;
      emit(OnboardingStepChanged(step: _currentStep));
    }
  }

  void updateName(String name) => _profile.name = name;
  void updateBirthDate(DateTime? date) => _profile.birthDate = date;
  void updateSex(String? sex) => _profile.sex = sex;
  void updateWeight(double? weight) => _profile.weightKg = weight;
  void updateHeight(double? height) => _profile.heightCm = height;
  void updateConditions(List<String> conditions) => _profile.conditions = conditions;
  void updateFamilyHistory(List<String> history) => _profile.familyHistory = history;
  void updateMedications(List<String> medications) => _profile.medications = medications;
  void updateAllergies(List<String> allergies) => _profile.allergies = allergies;

  Future<void> saveAndComplete() async {
    emit(OnboardingLoading());
    try {
      final profile = up.UserProfile(
        name: _profile.name,
        age: _profile.age,
        weight: _profile.weightKg,
        height: _profile.heightCm,
      );
      await _userProfileRepository.saveUserProfile(profile);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_completed', true);

      emit(OnboardingComplete());
    } catch (e) {
      emit(OnboardingError(e.toString()));
    }
  }
}
