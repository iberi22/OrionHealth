import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/network/incentives/domain/entities/contribution.dart';
import 'package:orionhealth_health/features/network/incentives/domain/entities/reward.dart';
import 'package:orionhealth_health/features/network/incentives/domain/repositories/incentive_repository.dart';

class MockIncentiveRepository extends Mock implements IncentiveRepository {}

void main() {
  group('IncentiveRepository', () {
    late IncentiveRepository repository;

    setUp(() {
      repository = MockIncentiveRepository();
    });

    test('can be mocked', () async {
      const userId = 'user1';
      final contributions = [
        Contribution(
          id: '1',
          userId: userId,
          type: ContributionType.storage,
          rewardPoints: 10,
          timestamp: DateTime.now(),
        ),
      ];

      when(() => repository.getContributions(userId))
          .thenAnswer((_) async => contributions);

      final result = await repository.getContributions(userId);
      expect(result, contributions);
    });

    test('getRewards returns rewards list', () async {
      const userId = 'user1';
      final rewards = [
        const Reward(
          id: '1',
          userId: userId,
          points: 100,
          tier: 'Silver',
          isClaimed: false,
        ),
      ];

      when(() => repository.getRewards(userId))
          .thenAnswer((_) async => rewards);

      final result = await repository.getRewards(userId);
      expect(result, rewards);
    });
  });
}
