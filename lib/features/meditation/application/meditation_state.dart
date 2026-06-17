import 'package:equatable/equatable.dart';
import '../meditation_models.dart';

abstract class MeditationState extends Equatable {
  const MeditationState();

  @override
  List<Object?> get props => [];
}

class MeditationInitial extends MeditationState {}

class MeditationLoading extends MeditationState {}

class MeditationLoaded extends MeditationState {
  final List<MeditationScript> scripts;
  final MeditationProgress progress;

  const MeditationLoaded({
    required this.scripts,
    required this.progress,
  });

  @override
  List<Object?> get props => [scripts, progress];
}

class MeditationError extends MeditationState {
  final String message;

  const MeditationError(this.message);

  @override
  List<Object?> get props => [message];
}
