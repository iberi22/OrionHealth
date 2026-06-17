import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../domain/entities/reputation_badge.dart';
import '../domain/services/badge_calculator.dart';

class BadgeState {
  final BadgeLevel? currentLevel;
  final bool isLoading;
  final String? error;

  BadgeState({
    this.currentLevel,
    this.isLoading = false,
    this.error,
  });

  BadgeState copyWith({
    BadgeLevel? currentLevel,
    bool? isLoading,
    String? error,
  }) {
    return BadgeState(
      currentLevel: currentLevel ?? this.currentLevel,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

@injectable
class BadgeCubit extends Cubit<BadgeState> {
  final BadgeCalculator _badgeCalculator;

  BadgeCubit(this._badgeCalculator) : super(BadgeState());

  Future<void> refreshBadge(String doctorId) async {
    emit(state.copyWith(isLoading: true));
    try {
      final level = await _badgeCalculator.calculateBadge(doctorId);
      emit(state.copyWith(currentLevel: level, isLoading: false));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }
}
