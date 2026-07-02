import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/core/di/injection.dart';
import 'package:orionhealth_health/features/network/incentives/application/incentive_cubit.dart';
import 'package:orionhealth_health/features/network/incentives/presentation/pages/leaderboard_page.dart';

class MockIncentiveCubit extends Mock implements IncentiveCubit {}

void main() {
  late MockIncentiveCubit mockCubit;

  setUp(() async {
    await getIt.reset();
    mockCubit = MockIncentiveCubit();
    when(() => mockCubit.state).thenReturn(const IncentiveState());
    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockCubit.leaderboard()).thenAnswer((_) async {});
    when(() => mockCubit.close()).thenAnswer((_) async {});

    getIt.registerSingleton<IncentiveCubit>(mockCubit);
  });

  testWidgets('LeaderboardPage displays loading indicator when status is loading', (WidgetTester tester) async {
    when(() => mockCubit.state).thenReturn(const IncentiveState(status: IncentiveStatus.loading));

    await tester.pumpWidget(
      const MaterialApp(
        home: LeaderboardPage(),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('LeaderboardPage displays empty message when no leaderboard data', (WidgetTester tester) async {
    when(() => mockCubit.state).thenReturn(const IncentiveState(status: IncentiveStatus.loaded, leaderboard: {}));

    await tester.pumpWidget(
      const MaterialApp(
        home: LeaderboardPage(),
      ),
    );

    expect(find.text('Aún no hay datos en el leaderboard'), findsOneWidget);
  });

  testWidgets('LeaderboardPage displays sorted leaderboard list', (WidgetTester tester) async {
    final leaderboard = {
      'User A': 100,
      'User B': 300,
      'User C': 200,
    };

    when(() => mockCubit.state).thenReturn(IncentiveState(
      status: IncentiveStatus.loaded,
      leaderboard: leaderboard,
    ));

    await tester.pumpWidget(
      const MaterialApp(
        home: LeaderboardPage(),
      ),
    );

    expect(find.text('User B'), findsOneWidget);
    expect(find.text('300 pts'), findsOneWidget);
    expect(find.text('User C'), findsOneWidget);
    expect(find.text('200 pts'), findsOneWidget);
    expect(find.text('User A'), findsOneWidget);
    expect(find.text('100 pts'), findsOneWidget);

    // Verify order (User B should be first)
    // ignore: unused_local_variable
    final textB = tester.widget<Text>(find.text('User B'));
    // ignore: unused_local_variable
    final textC = tester.widget<Text>(find.text('User C'));

    final posB = tester.getCenter(find.text('User B'));
    final posC = tester.getCenter(find.text('User C'));

    expect(posB.dy < posC.dy, isTrue);
  });
}
