import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/network/incentives/domain/entities/contribution.dart';

void main() {
  group('Contribution', () {
    final timestamp = DateTime.now();
    test('supports value equality', () {
      expect(
        Contribution(
          id: '1',
          userId: 'user1',
          type: ContributionType.storage,
          rewardPoints: 10,
          timestamp: timestamp,
        ),
        equals(
          Contribution(
            id: '1',
            userId: 'user1',
            type: ContributionType.storage,
            rewardPoints: 10,
            timestamp: timestamp,
          ),
        ),
      );
    });

    test('props are correct', () {
      final contribution = Contribution(
        id: '1',
        userId: 'user1',
        type: ContributionType.storage,
        rewardPoints: 10,
        timestamp: timestamp,
      );
      expect(contribution.props, ['1', 'user1', ContributionType.storage, 10, timestamp]);
    });

    test('different values are not equal', () {
       expect(
        Contribution(
          id: '1',
          userId: 'user1',
          type: ContributionType.storage,
          rewardPoints: 10,
          timestamp: timestamp,
        ),
        isNot(equals(
          Contribution(
            id: '2',
            userId: 'user1',
            type: ContributionType.storage,
            rewardPoints: 10,
            timestamp: timestamp,
          ),
        )),
      );
    });
  });
}
