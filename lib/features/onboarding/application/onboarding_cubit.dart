import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../domain/entities/user_profile.dart';
import '../domain/services/profile_analysis_service.dart';

// ============================================================================
// STATES
// ============================================================================

abstract class OnboardingState extends Equatable {
  const OnboardingState();

  @override
  List<Object?> get props => [];
}

class OnboardingInitial extends OnboardingState {}

class OnboardingLoading extends OnboardingState {
  final String message;
  const OnboardingLoading([this.message = 'Cargando...']);

  @override
  List<Object?> get props => [message];
}

class OnboardingInProgress extends OnboardingState {
  final int currentStep;
  final int totalSteps;
  final UserProfile profile;

  const OnboardingInProgress({
    required this.currentStep,
    required this.totalSteps,
    required this.profile,
  });

  double get progress => (currentStep + 1) / totalSteps;

  @override
  List<Object?> get props => [currentStep, totalSteps, profile];

  OnboardingInProgress copyWith({
    int? currentStep,
    int? totalSteps,
    UserProfile? profile,
  }) {
    return OnboardingInProgress(
      currentStep: currentStep ?? this.currentStep,
      totalSteps: totalSteps ?? this.totalSteps,
      profile: profile ?? this.profile,
    );
  }
}

class OnboardingSyncing extends OnboardingState {
  final double progress;
  final String message;

  const OnboardingSyncing({
    required this.progress,
    required this.message,
  });

  @override
  List<Object?> get props => [progress, message];
}

class OnboardingCompleted extends OnboardingState {
  final UserProfile profile;

  const OnboardingCompleted({required this.profile});

  @override
  List<Object?> get props => [profile];
}

class OnboardingError extends OnboardingState {
  final String message;

  const OnboardingError({required this.message});

  @override
  List<Object?> get props => [message];
}

// ============================================================================
// ONBOARDING STEPS
// ============================================================================

enum OnboardingStep {
  welcome(0, 'Bienvenida'),
  basicInfo(1, 'Datos Personales'),
  conditions(2, 'Condiciones'),
  familyHistory(3, 'Antecedentes'),
  medications(4, 'Medicamentos'),
  privacy(5, 'Privacidad'),
  complete(6, 'Completado');

  final int index;
  final String title;

  const OnboardingStep(this.index, this.title);

  static OnboardingStep fromIndex(int index) {
    return OnboardingStep.values.firstWhere(
      (step) => step.index == index,
      orElse: () => OnboardingStep.welcome,
    );
  }
}

// ============================================================================
// CUBIT
// ============================================================================

class OnboardingCubit extends Cubit<OnboardingState> {
  final ProfileAnalysisService _analysisService;

  OnboardingCubit({
    ProfileAnalysisService? analysisService,
  })  : _analysisService = analysisService ?? ProfileAnalysisService(),
        super(OnboardingInitial());

  static const int totalSteps = OnboardingStep.values.length;

  /// Start onboarding flow
  Future<void> startOnboarding() async {
    emit(const OnboardingLoading('Iniciando...'));

    final now = DateTime.now();
    final profile = UserProfile(
      createdAt: now,
      updatedAt: now,
      onboardingStep: 0,
      onboardingCompleted: false,
    );

    emit(OnboardingInProgress(
      currentStep: 0,
      totalSteps: totalSteps,
      profile: profile,
    ));
  }

  /// Resume onboarding from last step
  Future<void> resumeOnboarding(UserProfile savedProfile) async {
    emit(const OnboardingLoading('Resumiendo...'));

    emit(OnboardingInProgress(
      currentStep: savedProfile.onboardingStep,
      totalSteps: totalSteps,
      profile: savedProfile,
    ));
  }

  /// Update basic info (step 1)
  Future<void> updateBasicInfo({
    required String name,
    required DateTime birthDate,
    required String sex,
    double? weightKg,
    double? heightCm,
  }) async {
    final currentState = state;
    if (currentState is! OnboardingInProgress) return;

    final updatedProfile = currentState.profile.copyWith(
      name: name,
      birthDate: birthDate,
      sex: sex,
      weightKg: weightKg,
      heightCm: heightCm,
      updatedAt: DateTime.now(),
    );

    emit(currentState.copyWith(
      currentStep: OnboardingStep.basicInfo.index,
      profile: updatedProfile,
    ));
  }

  /// Update conditions (step 2)
  Future<void> updateConditions(List<String> conditions) async {
    final currentState = state;
    if (currentState is! OnboardingInProgress) return;

    final updatedProfile = currentState.profile.copyWith(
      conditions: conditions,
      updatedAt: DateTime.now(),
    );

    emit(currentState.copyWith(
      currentStep: OnboardingStep.conditions.index,
      profile: updatedProfile,
    ));
  }

  /// Update family history (step 3)
  Future<void> updateFamilyHistory(List<String> familyHistory) async {
    final currentState = state;
    if (currentState is! OnboardingInProgress) return;

    final updatedProfile = currentState.profile.copyWith(
      familyHistory: familyHistory,
      updatedAt: DateTime.now(),
    );

    emit(currentState.copyWith(
      currentStep: OnboardingStep.familyHistory.index,
      profile: updatedProfile,
    ));
  }

  /// Update medications (step 4)
  Future<void> updateMedications(List<String> medications) async {
    final currentState = state;
    if (currentState is! OnboardingInProgress) return;

    final updatedProfile = currentState.profile.copyWith(
      medications: medications,
      updatedAt: DateTime.now(),
    );

    emit(currentState.copyWith(
      currentStep: OnboardingStep.medications.index,
      profile: updatedProfile,
    ));
  }

  /// Accept privacy consent (step 5)
  Future<void> acceptPrivacyConsent({
    required bool consent,
    String? locale,
  }) async {
    final currentState = state;
    if (currentState is! OnboardingInProgress) return;

    final updatedProfile = currentState.profile.copyWith(
      privacyConsent: consent,
      locale: locale,
      updatedAt: DateTime.now(),
    );

    emit(currentState.copyWith(
      currentStep: OnboardingStep.privacy.index,
      profile: updatedProfile,
    ));
  }

  /// Complete onboarding and trigger selective sync
  Future<void> completeOnboarding() async {
    final currentState = state;
    if (currentState is! OnboardingInProgress) return;

    emit(const OnboardingSyncing(
      progress: 0,
      message: 'Preparando...',
    ));

    // Analyze profile to determine relevant standards
    emit(const OnboardingSyncing(
      progress: 0.1,
      message: 'Analizando perfil...',
    ));

    final relevantStandards = _analysisService.analyzeProfile(
      currentState.profile,
    );

    emit(OnboardingSyncing(
      progress: 0.2,
      message:
          'Descargando ${relevantStandards.estimatedSizeMB} MB de estándares médicos...',
    ));

    // Simulate sync progress (actual implementation would use SelectiveSyncService)
    for (int i = 30; i <= 90; i += 20) {
      await Future.delayed(const Duration(milliseconds: 200));
      emit(OnboardingSyncing(
        progress: i / 100,
        message: 'Sincronizando datos médicos...',
      ));
    }

    emit(const OnboardingSyncing(
      progress: 0.95,
      message: 'Finalizando...',
    ));

    final completedProfile = currentState.profile.copyWith(
      onboardingStep: OnboardingStep.complete.index,
      onboardingCompleted: true,
      updatedAt: DateTime.now(),
    );

    emit(OnboardingCompleted(profile: completedProfile));
  }

  /// Go to next step
  Future<void> nextStep() async {
    final currentState = state;
    if (currentState is! OnboardingInProgress) return;

    if (currentState.currentStep < totalSteps - 1) {
      final updatedProfile = currentState.profile.copyWith(
        onboardingStep: currentState.currentStep + 1,
        updatedAt: DateTime.now(),
      );

      emit(currentState.copyWith(
        currentStep: currentState.currentStep + 1,
        profile: updatedProfile,
      ));
    }
  }

  /// Go to previous step
  Future<void> previousStep() async {
    final currentState = state;
    if (currentState is! OnboardingInProgress) return;

    if (currentState.currentStep > 0) {
      final updatedProfile = currentState.profile.copyWith(
        onboardingStep: currentState.currentStep - 1,
        updatedAt: DateTime.now(),
      );

      emit(currentState.copyWith(
        currentStep: currentState.currentStep - 1,
        profile: updatedProfile,
      ));
    }
  }

  /// Skip onboarding (for testing or power users)
  Future<void> skipOnboarding() async {
    final currentState = state;
    if (currentState is! OnboardingInProgress) return;

    final skippedProfile = currentState.profile.copyWith(
      onboardingStep: totalSteps - 1,
      onboardingCompleted: true,
      updatedAt: DateTime.now(),
    );

    emit(OnboardingCompleted(profile: skippedProfile));
  }

  /// Reset onboarding state
  void reset() {
    emit(OnboardingInitial());
  }
}
