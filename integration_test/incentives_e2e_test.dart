import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:orionhealth_health/features/network/incentives/presentation/pages/incentives_page.dart';
import 'package:orionhealth_health/features/network/incentives/application/incentive_cubit.dart';
import 'package:orionhealth_health/features/network/incentives/domain/entities/reward.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/core/di/injection.dart';
import 'utils/video_recorder.dart';

class MockIncentiveCubit extends Mock implements IncentiveCubit {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockIncentiveCubit mockCubit;
  late StreamController<IncentiveState> stateController;

  setUp(() {
    mockCubit = MockIncentiveCubit();
    stateController = StreamController<IncentiveState>.broadcast();

    getIt.allowReassignment = true;
    getIt.registerSingleton<IncentiveCubit>(mockCubit);

    when(() => mockCubit.loadIncentiveData(any())).thenAnswer((_) async {});
    when(() => mockCubit.stream).thenAnswer((_) => stateController.stream);
  });

  tearDown(() {
    getIt.unregister<IncentiveCubit>();
    stateController.close();
  });

  group('Incentives Flow - E2E Tests', () {
    testWidgets('E2E: Contributions and Rewards', (WidgetTester tester) async {
      when(() => mockCubit.state).thenReturn(const IncentiveState(
        status: IncentiveStatus.loaded,
        totalPoints: 1500,
      ));

      await tester.pumpWidget(const MaterialApp(home: IncentivesPage(userId: 'user1')));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'incentives', '01_dashboard');

      expect(find.text('1500'), findsOneWidget);
      expect(find.text('TOTAL DE PUNTOS'), findsOneWidget);
    });

    testWidgets('E2E: Reward Claim with Insufficient Balance', (WidgetTester tester) async {
      final reward = Reward(
        id: 'r1',
        userId: 'user1',
        points: 2000,
        tier: 'Standard',
        isClaimed: false,
      );

      when(() => mockCubit.state).thenReturn(IncentiveState(
        status: IncentiveStatus.loaded,
        totalPoints: 1500,
        rewards: [reward],
      ));

      await tester.pumpWidget(const MaterialApp(home: IncentivesPage(userId: 'user1')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('RECOMPENSAS'));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'incentives', '02_rewards_page');

      expect(find.text('Recompensa Standard'), findsOneWidget);
      expect(find.text('2000 puntos requeridos'), findsOneWidget);

      when(() => mockCubit.claimReward(any(), any())).thenAnswer((_) async {
        final errorState = const IncentiveState(
          status: IncentiveStatus.error,
          errorMessage: 'Insufficient points balance',
          totalPoints: 1500,
        );
        when(() => mockCubit.state).thenReturn(errorState);
        stateController.add(errorState);
      });

      await tester.tap(find.text('RECLAMAR'));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'incentives', '03_claim_error');

      expect(find.text('Error: Insufficient points balance'), findsOneWidget);
    });
  });
}
