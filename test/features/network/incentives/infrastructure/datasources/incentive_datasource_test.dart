import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/network/incentives/domain/entities/contribution.dart';
import 'package:orionhealth_health/features/network/incentives/infrastructure/datasources/incentive_datasource.dart';

void main() {
  late IncentiveDatasource datasource;

  setUp(() {
    datasource = IncentiveDatasource();
  });

  group('IncentiveDatasource', () {
    const userId = 'user1';
    final contribution = Contribution(
      id: 'c1',
      userId: userId,
      type: ContributionType.storage,
      rewardPoints: 50,
      timestamp: DateTime.now(),
    );

    test('addContribution adds a contribution and getTotalPoints reflects it', () async {
      await datasource.addContribution(contribution);
      final points = await datasource.getTotalPoints(userId);
      expect(points, 50);
    });

    test('getContributions returns contributions for the user', () async {
      await datasource.addContribution(contribution);
      final contributions = await datasource.getContributions(userId);
      expect(contributions.length, 1);
      expect(contributions.first.id, 'c1');
    });

    test('getContributions returns empty list for user with no contributions', () async {
      final contributions = await datasource.getContributions('unknown_user');
      expect(contributions, isEmpty);
    });

    test('addContribution generates a reward when points threshold is met', () async {
      final c1 = Contribution(
        id: 'c1',
        userId: userId,
        type: ContributionType.storage,
        rewardPoints: 60,
        timestamp: DateTime.now(),
      );
      final c2 = Contribution(
        id: 'c2',
        userId: userId,
        type: ContributionType.storage,
        rewardPoints: 50,
        timestamp: DateTime.now(),
      );

      await datasource.addContribution(c1);
      var rewards = await datasource.getRewards(userId);
      expect(rewards.isEmpty, true);

      await datasource.addContribution(c2);
      rewards = await datasource.getRewards(userId);
      expect(rewards.length, 1);
      expect(rewards.first.tier, 'Bronze');
      expect(rewards.first.points, 100);
    });

    test('claimReward marks reward as claimed and triggers token distribution', () async {
      final c1 = Contribution(
        id: 'c1',
        userId: userId,
        type: ContributionType.storage,
        rewardPoints: 110,
        timestamp: DateTime.now(),
      );
      await datasource.addContribution(c1);
      final rewards = await datasource.getRewards(userId);
      final rewardId = rewards.first.id;

      await datasource.claimReward(rewardId);

      final updatedRewards = await datasource.getRewards(userId);
      expect(updatedRewards.first.isClaimed, true);
    });

    test('getLeaderboard returns sorted leaderboard', () async {
      await datasource.addContribution(Contribution(
        id: 'c1', userId: 'u1', type: ContributionType.storage, rewardPoints: 100, timestamp: DateTime.now(),
      ));
      await datasource.addContribution(Contribution(
        id: 'c2', userId: 'u2', type: ContributionType.storage, rewardPoints: 200, timestamp: DateTime.now(),
      ));

      final leaderboard = await datasource.getLeaderboard();
      expect(leaderboard.keys.first, 'u2');
      expect(leaderboard['u2'], 200);
      expect(leaderboard['u1'], 100);
    });

    test('handling multiple users separately', () async {
       await datasource.addContribution(Contribution(
        id: 'c1', userId: 'u1', type: ContributionType.storage, rewardPoints: 100, timestamp: DateTime.now(),
      ));
      await datasource.addContribution(Contribution(
        id: 'c2', userId: 'u2', type: ContributionType.storage, rewardPoints: 200, timestamp: DateTime.now(),
      ));

      expect(await datasource.getTotalPoints('u1'), 100);
      expect(await datasource.getTotalPoints('u2'), 200);

      final contributionsU1 = await datasource.getContributions('u1');
      expect(contributionsU1.length, 1);
      expect(contributionsU1.first.userId, 'u1');
    });
  });
}
