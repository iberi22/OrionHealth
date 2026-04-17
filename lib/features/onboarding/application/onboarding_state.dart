part of 'onboarding_cubit.dart';

abstract class OnboardingState extends Equatable {
  const OnboardingState();

  @override
  List<Object?> get props => [];
}

class OnboardingInitial extends OnboardingState { const OnboardingInitial();}

class OnboardingStepChanged extends OnboardingState {
  final int step;
  const OnboardingStepChanged({required this.step});

  @override
  List<Object?> get props => [step];
}

class OnboardingLoading extends OnboardingState { const OnboardingLoading();}

class OnboardingComplete extends OnboardingState { const OnboardingComplete();}

class OnboardingError extends OnboardingState {
  final String message;
  const OnboardingError(this.message);

  @override
  List<Object?> get props => [message];
}
