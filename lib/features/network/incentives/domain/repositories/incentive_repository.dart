import '../entities/contribution.dart';
import '../entities/reward.dart';

abstract class IncentiveRepository {
  Future<void> addContribution(Contribution contribution);
  Future<List<Contribution>> getContributions(String userId);
  Future<List<Reward>> getRewards(String userId);
  Future<void> claimReward(String rewardId);
  Future<Map<String, int>> getLeaderboard();
  Future<int> getTotalPoints(String userId);
}
