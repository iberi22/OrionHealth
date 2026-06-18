import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/core/di/injection.dart';
import 'package:orionhealth_health/features/network/incentives/application/incentive_cubit.dart';
import 'package:orionhealth_health/features/network/incentives/domain/entities/contribution.dart';
import 'package:orionhealth_health/features/network/incentives/presentation/pages/incentives_page.dart';
import 'package:orionhealth_health/features/network/incentives/presentation/widgets/contribution_card.dart';

class MockIncentiveCubit extends Mock implements IncentiveCubit {}

void main() {
  late MockIncentiveCubit mockCubit;

  setUp(() async {
    await getIt.reset();
    mockCubit = MockIncentiveCubit();

    when(() => mockCubit.state).thenReturn(const IncentiveState());
    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockCubit.loadIncentiveData(any())).thenAnswer((_) async {});
    when(() => mockCubit.close()).thenAnswer((_) async {});

    getIt.registerSingleton<IncentiveCubit>(mockCubit);
  });

  testWidgets('IncentivesPage displays loading indicator when status is loading', (WidgetTester tester) async {
    when(() => mockCubit.state).thenReturn(const IncentiveState(status: IncentiveStatus.loading));

    await tester.pumpWidget(
      const MaterialApp(
        home: IncentivesPage(userId: 'user1'),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('IncentivesPage displays points and contributions when loaded', (WidgetTester tester) async {
    final contributions = [
      Contribution(
        id: '1',
        userId: 'user1',
        type: ContributionType.storage,
        rewardPoints: 100,
        timestamp: DateTime.now(),
      ),
    ];

    when(() => mockCubit.state).thenReturn(IncentiveState(
      status: IncentiveStatus.loaded,
      totalPoints: 1250,
      contributions: contributions,
    ));

    await tester.pumpWidget(
      const MaterialApp(
        home: IncentivesPage(userId: 'user1'),
      ),
    );

    expect(find.text('1250'), findsOneWidget);
    expect(find.text('CONTRIBUCIONES RECIENTES'), findsOneWidget);
    expect(find.byType(ContributionCard), findsOneWidget);
  });
}
