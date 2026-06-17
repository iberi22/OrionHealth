import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import '../domain/entities/contribution.dart';
import '../domain/entities/reward.dart';
import '../domain/repositories/incentive_repository.dart';

enum IncentiveStatus { initial, loading, loaded, error }

class IncentiveState extends Equatable {
  final List<Contribution> contributions;
  final List<Reward> rewards;
  final Map<String, int> leaderboard;
  final int totalPoints;
  final IncentiveStatus status;
  final String? errorMessage;

  const IncentiveState({
    this.contributions = const [],
    this.rewards = const [],
    this.leaderboard = const {},
    this.totalPoints = 0,
    this.status = IncentiveStatus.initial,
    this.errorMessage,
  });

  IncentiveState copyWith({
    List<Contribution>? contributions,
    List<Reward>? rewards,
    Map<String, int>? leaderboard,
    int? totalPoints,
    IncentiveStatus? status,
    String? errorMessage,
  }) {
    return IncentiveState(
      contributions: contributions ?? this.contributions,
      rewards: rewards ?? this.rewards,
      leaderboard: leaderboard ?? this.leaderboard,
      totalPoints: totalPoints ?? this.totalPoints,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [contributions, rewards, leaderboard, totalPoints, status, errorMessage];
}

class IncentiveCubit extends Cubit<IncentiveState> {
  final IncentiveRepository _repository;
  final _uuid = const Uuid();

  IncentiveCubit(this._repository) : super(const IncentiveState());

  Future<void> loadIncentiveData(String userId) async {
    emit(state.copyWith(status: IncentiveStatus.loading));
    try {
      final contributions = await _repository.getContributions(userId);
      final rewards = await _repository.getRewards(userId);
      final totalPoints = await _repository.getTotalPoints(userId);
      final leaderboard = await _repository.getLeaderboard();

      emit(state.copyWith(
        status: IncentiveStatus.loaded,
        contributions: contributions,
        rewards: rewards,
        totalPoints: totalPoints,
        leaderboard: leaderboard,
      ));
    } catch (e) {
      emit(state.copyWith(status: IncentiveStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> contribute(String userId, ContributionType type, int points) async {
    final contribution = Contribution(
      id: _uuid.v4(),
      userId: userId,
      type: type,
      rewardPoints: points,
      timestamp: DateTime.now(),
    );

    try {
      await _repository.addContribution(contribution);
      await loadIncentiveData(userId);
    } catch (e) {
      emit(state.copyWith(status: IncentiveStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> claimReward(String userId, String rewardId) async {
    try {
      await _repository.claimReward(rewardId);
      await loadIncentiveData(userId);
    } catch (e) {
      emit(state.copyWith(status: IncentiveStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> leaderboard() async {
    try {
      final leaderboard = await _repository.getLeaderboard();
      emit(state.copyWith(leaderboard: leaderboard));
    } catch (e) {
      emit(state.copyWith(status: IncentiveStatus.error, errorMessage: e.toString()));
    }
  }
}
