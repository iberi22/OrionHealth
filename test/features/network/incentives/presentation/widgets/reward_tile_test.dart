import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/network/incentives/domain/entities/reward.dart';
import 'package:orionhealth_health/features/network/incentives/presentation/widgets/reward_tile.dart';

void main() {
  const unclaimedReward = Reward(
    id: '1',
    userId: 'user1',
    points: 100,
    tier: 'Bronze',
    isClaimed: false,
  );

  const claimedReward = Reward(
    id: '2',
    userId: 'user1',
    points: 500,
    tier: 'Gold',
    isClaimed: true,
  );

  testWidgets('RewardTile renders unclaimed reward correctly', (WidgetTester tester) async {
    bool claimed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RewardTile(
            reward: unclaimedReward,
            onClaim: () => claimed = true,
          ),
        ),
      ),
    );

    expect(find.text('Recompensa Bronze'), findsOneWidget);
    expect(find.text('100 puntos requeridos'), findsOneWidget);
    expect(find.text('RECLAMAR'), findsOneWidget);
    expect(find.text('RECLAMADO'), findsNothing);

    await tester.tap(find.text('RECLAMAR'));
    expect(claimed, isTrue);
  });

  testWidgets('RewardTile renders claimed reward correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RewardTile(
            reward: claimedReward,
          ),
        ),
      ),
    );

    expect(find.text('Recompensa Gold'), findsOneWidget);
    expect(find.text('500 puntos requeridos'), findsOneWidget);
    expect(find.text('RECLAMADO'), findsOneWidget);
    expect(find.text('RECLAMAR'), findsNothing);
  });
}
