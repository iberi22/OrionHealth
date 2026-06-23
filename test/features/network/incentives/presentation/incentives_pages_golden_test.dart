import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:orionhealth_health/features/network/incentives/application/incentive_cubit.dart';
import 'package:orionhealth_health/features/network/incentives/domain/entities/contribution.dart';
import 'package:orionhealth_health/features/network/incentives/domain/entities/reward.dart';
import 'package:orionhealth_health/features/network/incentives/presentation/pages/incentives_page.dart';
import 'package:orionhealth_health/features/network/incentives/presentation/pages/leaderboard_page.dart';
import 'package:orionhealth_health/features/network/incentives/presentation/pages/rewards_page.dart';
import 'package:orionhealth_health/features/network/incentives/presentation/widgets/contribution_card.dart';
import 'package:orionhealth_health/features/network/incentives/presentation/widgets/reward_tile.dart';
import '../../../../core/golden_test_utils.dart';

class MockIncentiveCubit extends Mock implements IncentiveCubit {}

void main() {
  late MockIncentiveCubit mockCubit;

  setUp(() {
    mockCubit = MockIncentiveCubit();
    when(() => mockCubit.state).thenReturn(const IncentiveState());
    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockCubit.loadIncentiveData(any())).thenAnswer((_) async {});
  });

  final testContribution = Contribution(
    id: '1',
    userId: 'user123',
    type: ContributionType.dataSharing,
    rewardPoints: 100,
    timestamp: DateTime(2025, 1, 1),
  );

  final testReward = Reward(
    id: '1',
    userId: 'user123',
    points: 500,
    tier: 'Gold',
    isClaimed: false,
  );

  group('Incentives Golden Tests', () {
    testWidgets('IncentivesPage', (tester) async {
      setupGoldenTest(tester);
      when(() => mockCubit.state).thenReturn(IncentiveState(
        status: IncentiveStatus.loaded,
        totalPoints: 1200,
        contributions: [testContribution],
      ));

      await tester.pumpWidget(wrapWithMaterial(
        BlocProvider<IncentiveCubit>.value(
          value: mockCubit,
          child: const IncentivesPage(userId: 'user123'),
        ),
      ));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(IncentivesPage),
        matchesGoldenFile("../../../../golden/reference/incentives_page.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('LeaderboardPage', (tester) async {
      setupGoldenTest(tester);
      when(() => mockCubit.state).thenReturn(const IncentiveState(
        status: IncentiveStatus.loaded,
        leaderboard: {
          'Alice': 5000,
          'Bob': 4500,
        },
      ));

      await tester.pumpWidget(wrapWithMaterial(
        BlocProvider<IncentiveCubit>.value(
          value: mockCubit,
          child: const LeaderboardPage(),
        ),
      ));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(LeaderboardPage),
        matchesGoldenFile("../../../../golden/reference/leaderboard_page.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('RewardsPage', (tester) async {
      setupGoldenTest(tester);
      when(() => mockCubit.state).thenReturn(IncentiveState(
        status: IncentiveStatus.loaded,
        rewards: [testReward],
        totalPoints: 1200,
      ));

      await tester.pumpWidget(wrapWithMaterial(
        BlocProvider<IncentiveCubit>.value(
          value: mockCubit,
          child: const RewardsPage(),
        ),
      ));
      await tester.pump(); // Use pump instead of pumpAndSettle

      await expectLater(
        find.byType(RewardsPage),
        matchesGoldenFile("../../../../golden/reference/rewards_page.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('ContributionCard', (tester) async {
      setupGoldenTest(tester);

      await tester.pumpWidget(wrapWithMaterial(
        Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ContributionCard(contribution: testContribution),
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(ContributionCard),
        matchesGoldenFile("../../../../golden/reference/contribution_card.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('RewardTile', (tester) async {
      setupGoldenTest(tester);

      await tester.pumpWidget(wrapWithMaterial(
        Scaffold(
          body: Center(
            child: RewardTile(
              reward: testReward,
              onClaim: () {},
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(RewardTile),
        matchesGoldenFile("../../../../golden/reference/reward_tile.png"),
      );
      resetGoldenTest(tester);
    });
  });
}
