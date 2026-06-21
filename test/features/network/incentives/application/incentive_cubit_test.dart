import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/network/incentives/application/incentive_cubit.dart';
import 'package:orionhealth_health/features/network/incentives/domain/entities/contribution.dart';
import 'package:orionhealth_health/features/network/incentives/domain/entities/reward.dart';
import 'package:orionhealth_health/features/network/incentives/domain/repositories/incentive_repository.dart';

class MockIncentiveRepository extends Mock implements IncentiveRepository {}

void main() {
  late IncentiveCubit cubit;
  late MockIncentiveRepository repository;

  setUpAll(() {
    registerFallbackValue(Contribution(
      id: '1',
      userId: 'user1',
      type: ContributionType.storage,
      rewardPoints: 10,
      timestamp: DateTime.now(),
    ));
  });

  setUp(() {
    repository = MockIncentiveRepository();
    cubit = IncentiveCubit(repository);
  });

  tearDown(() {
    cubit.close();
  });

  group('IncentiveCubit', () {
    test('initial state is correct', () {
      expect(cubit.state, const IncentiveState());
    });

    test('loadIncentiveData updates state with data from repository', () async {
      const userId = 'user1';
      final contributions = [
        Contribution(id: 'c1', userId: userId, type: ContributionType.storage, rewardPoints: 10, timestamp: DateTime.now()),
      ];
      final rewards = [
        const Reward(id: 'r1', userId: userId, points: 100, tier: 'Silver', isClaimed: false),
      ];
      final leaderboard = {'user1': 100, 'user2': 50};
      const totalPoints = 100;

      when(() => repository.getContributions(userId)).thenAnswer((_) async => contributions);
      when(() => repository.getRewards(userId)).thenAnswer((_) async => rewards);
      when(() => repository.getTotalPoints(userId)).thenAnswer((_) async => totalPoints);
      when(() => repository.getLeaderboard()).thenAnswer((_) async => leaderboard);

      await cubit.loadIncentiveData(userId);

      expect(cubit.state.status, IncentiveStatus.loaded);
      expect(cubit.state.contributions, contributions);
      expect(cubit.state.rewards, rewards);
      expect(cubit.state.totalPoints, totalPoints);
      expect(cubit.state.leaderboard, leaderboard);
    });

    test('loadIncentiveData emits error status on failure', () async {
      const userId = 'user1';
      when(() => repository.getContributions(userId)).thenThrow(Exception('Failed to load'));

      await cubit.loadIncentiveData(userId);

      expect(cubit.state.status, IncentiveStatus.error);
      expect(cubit.state.errorMessage, contains('Failed to load'));
    });

    test('contribute calls repository and reloads data', () async {
      const userId = 'user1';
      when(() => repository.addContribution(any())).thenAnswer((_) async => {});
      when(() => repository.getContributions(userId)).thenAnswer((_) async => []);
      when(() => repository.getRewards(userId)).thenAnswer((_) async => []);
      when(() => repository.getTotalPoints(userId)).thenAnswer((_) async => 0);
      when(() => repository.getLeaderboard()).thenAnswer((_) async => {});

      await cubit.contribute(userId, ContributionType.storage, 10);

      verify(() => repository.addContribution(any())).called(1);
      verify(() => repository.getContributions(userId)).called(1);
    });

    test('contribute emits error status on failure', () async {
      const userId = 'user1';
      when(() => repository.addContribution(any())).thenThrow(Exception('Failed to contribute'));

      await cubit.contribute(userId, ContributionType.storage, 10);

      expect(cubit.state.status, IncentiveStatus.error);
      expect(cubit.state.errorMessage, contains('Failed to contribute'));
    });

    test('claimReward calls repository and reloads data', () async {
      const userId = 'user1';
      const rewardId = 'r1';
      when(() => repository.claimReward(rewardId)).thenAnswer((_) async => {});
      when(() => repository.getContributions(userId)).thenAnswer((_) async => []);
      when(() => repository.getRewards(userId)).thenAnswer((_) async => []);
      when(() => repository.getTotalPoints(userId)).thenAnswer((_) async => 0);
      when(() => repository.getLeaderboard()).thenAnswer((_) async => {});

      await cubit.claimReward(userId, rewardId);

      verify(() => repository.claimReward(rewardId)).called(1);
      verify(() => repository.getRewards(userId)).called(1);
    });

    test('claimReward emits error status on failure', () async {
      const userId = 'user1';
      const rewardId = 'r1';
      when(() => repository.claimReward(rewardId)).thenThrow(Exception('Failed to claim'));

      await cubit.claimReward(userId, rewardId);

      expect(cubit.state.status, IncentiveStatus.error);
      expect(cubit.state.errorMessage, contains('Failed to claim'));
    });

    test('leaderboard updates leaderboard in state', () async {
      final leaderboard = {'u1': 1000};
      when(() => repository.getLeaderboard()).thenAnswer((_) async => leaderboard);

      await cubit.leaderboard();

      expect(cubit.state.leaderboard, leaderboard);
      verify(() => repository.getLeaderboard()).called(1);
    });

    test('leaderboard emits error status on failure', () async {
      when(() => repository.getLeaderboard()).thenThrow(Exception('Failed to get leaderboard'));

      await cubit.leaderboard();

      expect(cubit.state.status, IncentiveStatus.error);
      expect(cubit.state.errorMessage, contains('Failed to get leaderboard'));
    });
   group('IncentiveState', () {
      test('supports value equality', () {
        expect(const IncentiveState(), const IncentiveState());
      });

      test('props are correct', () {
        expect(
          const IncentiveState().props,
          [[], [], {}, 0, IncentiveStatus.initial, null],
        );
      });

      test('copyWith works correctly', () {
        expect(
          const IncentiveState().copyWith(status: IncentiveStatus.loading),
          const IncentiveState(status: IncentiveStatus.loading),
        );
      });
    });
  });
}
