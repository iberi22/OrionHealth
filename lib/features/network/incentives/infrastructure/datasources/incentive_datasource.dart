import 'package:injectable/injectable.dart';
import '../../domain/entities/contribution.dart';
import '../../domain/entities/reward.dart';

@lazySingleton
class IncentiveDatasource {
  // In-memory storage for the stub implementation
  final List<Contribution> _contributions = [];
  final List<Reward> _rewards = [];

  Future<void> addContribution(Contribution contribution) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 100));
    _contributions.add(contribution);

    // Auto-generate a reward if points exceed a threshold
    final totalPoints = await getTotalPoints(contribution.userId);
    if (totalPoints >= 100 && !_rewards.any((r) => r.userId == contribution.userId && r.tier == 'Bronze')) {
      _rewards.add(Reward(
        id: 'r-${DateTime.now().millisecondsSinceEpoch}',
        userId: contribution.userId,
        points: 100,
        tier: 'Bronze',
        isClaimed: false,
      ));
    }
  }

  Future<List<Contribution>> getContributions(String userId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _contributions.where((c) => c.userId == userId).toList();
  }

  Future<List<Reward>> getRewards(String userId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _rewards.where((r) => r.userId == userId).toList();
  }

  Future<void> claimReward(String rewardId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final index = _rewards.indexWhere((r) => r.id == rewardId);
    if (index != -1) {
      final reward = _rewards[index];
      if (!reward.isClaimed) {
        // Trigger token distribution contract
        await distributeTokens(reward.userId, reward.points);
        _rewards[index] = reward.copyWith(isClaimed: true);
      }
    }
  }

  Future<Map<String, int>> getLeaderboard() async {
    await Future.delayed(const Duration(milliseconds: 100));
    final Map<String, int> leaderboard = {};
    for (var c in _contributions) {
      leaderboard[c.userId] = (leaderboard[c.userId] ?? 0) + c.rewardPoints;
    }
    return Map.fromEntries(
      leaderboard.entries.toList()..sort((a, b) => b.value.compareTo(a.value)),
    );
  }

  Future<int> getTotalPoints(String userId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final userContributions = _contributions.where((c) => c.userId == userId);
    int sum = 0;
    for (var c in userContributions) {
      sum += c.rewardPoints;
    }
    return sum;
  }

  /// Token distribution contract interaction stub.
  /// In a real scenario, this would interact with a smart contract on-chain.
  Future<String> distributeTokens(String userId, int amount) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Simulate transaction hash
    return '0x${DateTime.now().millisecondsSinceEpoch.toRadixString(16)}distributionstub';
  }
}
