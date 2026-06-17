// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../core/services/audio/audio_player_service.dart';
import '../domain/usecases/complete_session_usecase.dart';
import '../domain/usecases/get_progress_usecase.dart';
import '../domain/usecases/recommend_script_usecase.dart';
import '../domain/usecases/start_session_usecase.dart';
import 'meditation_state.dart';

@injectable
class MeditationCubit extends Cubit<MeditationState> {
  final RecommendScriptUseCase _recommendScriptUseCase;
  final StartSessionUseCase _startSessionUseCase;
  final CompleteSessionUseCase _completeSessionUseCase;
  final GetProgressUseCase _getProgressUseCase;
  final AudioService _audioService;

  Timer? _timer;

  MeditationCubit(
    this._recommendScriptUseCase,
    this._startSessionUseCase,
    this._completeSessionUseCase,
    this._getProgressUseCase,
    this._audioService,
  ) : super(const MeditationState());

  Future<void> initialize() async {
    emit(state.copyWith(status: MeditationStatus.loading));
    try {
      final script = await _recommendScriptUseCase();
      final progress = await _getProgressUseCase();
      await _audioService.initialize();

      emit(state.copyWith(
        status: MeditationStatus.idle,
        script: script,
        steps: script.steps,
        progress: progress,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: MeditationStatus.error,
        error: e.toString(),
      ));
    }
  }

  Future<void> startMeditation() async {
    if (state.script == null) return;

    try {
      final session = await _startSessionUseCase(state.script!);
      emit(state.copyWith(
        status: MeditationStatus.playing,
        session: session,
        currentStep: 0,
        elapsedSeconds: 0,
      ));

      _startTimer();
      await _speakCurrentStep();
    } catch (e) {
      emit(state.copyWith(
        status: MeditationStatus.error,
        error: e.toString(),
      ));
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.status == MeditationStatus.playing) {
        final newElapsed = state.elapsedSeconds + 1;
        emit(state.copyWith(elapsedSeconds: newElapsed));

        if (newElapsed > 0 &&
            newElapsed % 45 == 0 &&
            state.currentStep < state.steps.length - 1) {
          nextStep();
        }
      }
    });
  }

  Future<void> nextStep() async {
    if (state.currentStep < state.steps.length - 1) {
      emit(state.copyWith(currentStep: state.currentStep + 1));
      await _speakCurrentStep();
    } else {
      await finishMeditation();
    }
  }

  Future<void> previousStep() async {
    if (state.currentStep > 0) {
      emit(state.copyWith(currentStep: state.currentStep - 1));
      await _speakCurrentStep();
    }
  }

  Future<void> togglePause() async {
    if (state.status == MeditationStatus.playing) {
      await _audioService.stopTTS();
      emit(state.copyWith(status: MeditationStatus.paused));
    } else if (state.status == MeditationStatus.paused) {
      emit(state.copyWith(status: MeditationStatus.playing));
      await _speakCurrentStep();
    }
  }

  Future<void> finishMeditation() async {
    _timer?.cancel();
    await _audioService.stopAll();

    if (state.session != null) {
      await _completeSessionUseCase(
        session: state.session!,
        elapsedSeconds: state.elapsedSeconds,
        completedSteps: state.currentStep + 1,
      );
    }

    final progress = await _getProgressUseCase();
    emit(state.copyWith(
      status: MeditationStatus.completed,
      progress: progress,
    ));

    await _audioService.speakText('La meditación ha terminado.');
  }

  Future<void> _speakCurrentStep() async {
    if (state.currentStep < state.steps.length) {
      await _audioService.speakText(state.steps[state.currentStep]);
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    _audioService.stopAll();
    return super.close();
  }
}
