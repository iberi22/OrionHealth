import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/network/incentives/application/incentive_cubit.dart';
import 'package:orionhealth_health/features/network/incentives/domain/entities/reward.dart';
import 'package:orionhealth_health/features/network/incentives/presentation/pages/rewards_page.dart';
import 'package:orionhealth_health/features/network/incentives/presentation/widgets/reward_tile.dart';

class MockIncentiveCubit extends Mock implements IncentiveCubit {}

void main() {
  late MockIncentiveCubit mockCubit;

  setUp(() {
    mockCubit = MockIncentiveCubit();
    when(() => mockCubit.state).thenReturn(const IncentiveState());
    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
  });

  testWidgets('RewardsPage displays empty message when no rewards', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<IncentiveCubit>.value(
          value: mockCubit,
          child: const RewardsPage(),
        ),
      ),
    );

    expect(find.text('No hay recompensas disponibles'), findsOneWidget);
  });

  testWidgets('RewardsPage displays list of rewards', (WidgetTester tester) async {
    const rewards = [
      Reward(id: '1', userId: 'user1', points: 100, tier: 'Bronze', isClaimed: false),
      Reward(id: '2', userId: 'user1', points: 200, tier: 'Silver', isClaimed: true),
    ];

    when(() => mockCubit.state).thenReturn(const IncentiveState(rewards: rewards));

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<IncentiveCubit>.value(
          value: mockCubit,
          child: const RewardsPage(),
        ),
      ),
    );

    expect(find.byType(RewardTile), findsNWidgets(2));
    expect(find.text('Recompensa Bronze'), findsOneWidget);
    expect(find.text('Recompensa Silver'), findsOneWidget);
  });

  testWidgets('RewardsPage calls claimReward when RECLAMAR is pressed', (WidgetTester tester) async {
    const rewards = [
      Reward(id: '1', userId: 'user1', points: 100, tier: 'Bronze', isClaimed: false),
    ];

    when(() => mockCubit.state).thenReturn(const IncentiveState(rewards: rewards));
    when(() => mockCubit.claimReward(any(), any())).thenAnswer((_) async {});

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<IncentiveCubit>.value(
          value: mockCubit,
          child: const RewardsPage(),
        ),
      ),
    );

    await tester.tap(find.text('RECLAMAR'));
    verify(() => mockCubit.claimReward('user1', '1')).called(1);
  });
}
