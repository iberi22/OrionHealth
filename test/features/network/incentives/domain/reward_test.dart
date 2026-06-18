import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/network/incentives/domain/entities/reward.dart';

void main() {
  group('Reward', () {
    test('supports value equality', () {
      expect(
        const Reward(
          id: '1',
          userId: 'user1',
          points: 100,
          tier: 'Silver',
          isClaimed: false,
        ),
        equals(
          const Reward(
            id: '1',
            userId: 'user1',
            points: 100,
            tier: 'Silver',
            isClaimed: false,
          ),
        ),
      );
    });

    test('copyWith works correctly', () {
      const reward = Reward(
        id: '1',
        userId: 'user1',
        points: 100,
        tier: 'Silver',
        isClaimed: false,
      );

      expect(
        reward.copyWith(isClaimed: true),
        const Reward(
          id: '1',
          userId: 'user1',
          points: 100,
          tier: 'Silver',
          isClaimed: true,
        ),
      );

      expect(
        reward.copyWith(points: 200),
        const Reward(
          id: '1',
          userId: 'user1',
          points: 200,
          tier: 'Silver',
          isClaimed: false,
        ),
      );
    });

    test('props are correct', () {
      const reward = Reward(
        id: '1',
        userId: 'user1',
        points: 100,
        tier: 'Silver',
        isClaimed: false,
      );
      expect(reward.props, ['1', 'user1', 100, 'Silver', false]);
    });
  });
}
