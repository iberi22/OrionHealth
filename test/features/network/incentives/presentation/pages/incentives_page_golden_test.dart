import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orionhealth_health/core/di/injection.dart';
import 'package:orionhealth_health/features/network/incentives/application/incentive_cubit.dart';
import 'package:orionhealth_health/features/network/incentives/domain/entities/contribution.dart';
import 'package:orionhealth_health/features/network/incentives/presentation/pages/incentives_page.dart';
import '../../../../../core/golden_test_utils.dart';

class MockIncentiveCubit extends Mock implements IncentiveCubit {}

void main() {
  late MockIncentiveCubit mockCubit;

  setUpAll(() {
    getIt.allowReassignment = true;
  });

  setUp(() {
    mockCubit = MockIncentiveCubit();
    when(() => mockCubit.loadIncentiveData(any())).thenAnswer((_) async {});
    when(() => mockCubit.close()).thenAnswer((_) async {});
    when(() => mockCubit.stream).thenAnswer((_) => const Stream<IncentiveState>.empty());

    getIt.registerSingleton<IncentiveCubit>(mockCubit);
  });

  tearDown(() {
    getIt.unregister<IncentiveCubit>();
  });

  group('IncentivesPage Golden Tests', () {
    testWidgets('Loaded state', (tester) async {
      final contributions = [
        Contribution(
          id: '1',
          userId: 'user1',
          type: ContributionType.dataSharing,
          rewardPoints: 100,
          timestamp: DateTime(2025, 1, 1),
        ),
      ];

      when(() => mockCubit.state).thenReturn(IncentiveState(
        status: IncentiveStatus.loaded,
        contributions: contributions,
        totalPoints: 1250,
      ));

      setupGoldenTest(tester);
      await tester.pumpWidget(wrapWithMaterial(
        const IncentivesPage(userId: 'user1'),
      ));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(IncentivesPage),
        matchesGoldenFile("goldens/incentives_page_loaded.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('Empty state', (tester) async {
      when(() => mockCubit.state).thenReturn(const IncentiveState(
        status: IncentiveStatus.loaded,
        contributions: [],
        totalPoints: 0,
      ));

      setupGoldenTest(tester);
      await tester.pumpWidget(wrapWithMaterial(
        const IncentivesPage(userId: 'user1'),
      ));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(IncentivesPage),
        matchesGoldenFile("goldens/incentives_page_empty.png"),
      );
      resetGoldenTest(tester);
    });
  });
}
