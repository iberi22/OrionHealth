import 'package:injectable/injectable.dart';
import '../../domain/entities/contribution.dart';
import '../../domain/entities/reward.dart';
import '../../domain/repositories/incentive_repository.dart';
import '../datasources/incentive_datasource.dart';

@LazySingleton(as: IncentiveRepository)
class IncentiveRepositoryImpl implements IncentiveRepository {
  final IncentiveDatasource _datasource;

  IncentiveRepositoryImpl(this._datasource);

  @override
  Future<void> addContribution(Contribution contribution) async {
    return _datasource.addContribution(contribution);
  }

  @override
  Future<void> claimReward(String rewardId) async {
    return _datasource.claimReward(rewardId);
  }

  @override
  Future<List<Contribution>> getContributions(String userId) async {
    return _datasource.getContributions(userId);
  }

  @override
  Future<Map<String, int>> getLeaderboard() async {
    return _datasource.getLeaderboard();
  }

  @override
  Future<List<Reward>> getRewards(String userId) async {
    return _datasource.getRewards(userId);
  }

  @override
  Future<int> getTotalPoints(String userId) async {
    return _datasource.getTotalPoints(userId);
  }
}
