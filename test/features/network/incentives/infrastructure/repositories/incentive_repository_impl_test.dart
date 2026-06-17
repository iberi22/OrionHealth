import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/network/incentives/domain/entities/contribution.dart';
import 'package:orionhealth_health/features/network/incentives/domain/entities/reward.dart';
import 'package:orionhealth_health/features/network/incentives/infrastructure/datasources/incentive_datasource.dart';
import 'package:orionhealth_health/features/network/incentives/infrastructure/repositories/incentive_repository_impl.dart';

class MockIncentiveDatasource extends Mock implements IncentiveDatasource {}

void main() {
  late IncentiveRepositoryImpl repository;
  late MockIncentiveDatasource datasource;

  setUp(() {
    datasource = MockIncentiveDatasource();
    repository = IncentiveRepositoryImpl(datasource);
  });

  group('IncentiveRepositoryImpl', () {
    const userId = 'user1';

    test('addContribution delegates to datasource', () async {
      final contribution = Contribution(
        id: 'c1',
        userId: userId,
        type: ContributionType.storage,
        rewardPoints: 10,
        timestamp: DateTime.now(),
      );
      when(() => datasource.addContribution(contribution)).thenAnswer((_) async => {});

      await repository.addContribution(contribution);

      verify(() => datasource.addContribution(contribution)).called(1);
    });

    test('getContributions delegates to datasource', () async {
      final contributions = [
        Contribution(id: 'c1', userId: userId, type: ContributionType.storage, rewardPoints: 10, timestamp: DateTime.now()),
      ];
      when(() => datasource.getContributions(userId)).thenAnswer((_) async => contributions);

      final result = await repository.getContributions(userId);

      expect(result, contributions);
      verify(() => datasource.getContributions(userId)).called(1);
    });

    test('getRewards delegates to datasource', () async {
      final rewards = [
        const Reward(id: 'r1', userId: userId, points: 100, tier: 'Bronze', isClaimed: false),
      ];
      when(() => datasource.getRewards(userId)).thenAnswer((_) async => rewards);

      final result = await repository.getRewards(userId);

      expect(result, rewards);
      verify(() => datasource.getRewards(userId)).called(1);
    });

    test('claimReward delegates to datasource', () async {
      const rewardId = 'r1';
      when(() => datasource.claimReward(rewardId)).thenAnswer((_) async => {});

      await repository.claimReward(rewardId);

      verify(() => datasource.claimReward(rewardId)).called(1);
    });

    test('getLeaderboard delegates to datasource', () async {
      final leaderboard = {'u1': 100};
      when(() => datasource.getLeaderboard()).thenAnswer((_) async => leaderboard);

      final result = await repository.getLeaderboard();

      expect(result, leaderboard);
      verify(() => datasource.getLeaderboard()).called(1);
    });

    test('getTotalPoints delegates to datasource', () async {
      when(() => datasource.getTotalPoints(userId)).thenAnswer((_) async => 100);

      final result = await repository.getTotalPoints(userId);

      expect(result, 100);
      verify(() => datasource.getTotalPoints(userId)).called(1);
    });
  });
}
