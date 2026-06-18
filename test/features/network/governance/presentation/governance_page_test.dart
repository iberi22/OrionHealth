import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/network/governance/application/governance_cubit.dart';
import 'package:orionhealth_health/features/network/governance/domain/entities/proposal.dart';
import 'package:orionhealth_health/features/network/governance/presentation/pages/governance_page.dart';
import 'package:orionhealth_health/features/network/governance/presentation/widgets/proposal_card.dart';

class MockGovernanceCubit extends Mock implements GovernanceCubit {}

void main() {
  late MockGovernanceCubit mockCubit;

  setUp(() {
    mockCubit = MockGovernanceCubit();
    // Use when stubbing since we can't use mock_test's whenListen
    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockCubit.isClosed).thenReturn(false);
    when(() => mockCubit.close()).thenAnswer((_) async => {});
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<GovernanceCubit>.value(
        value: mockCubit,
        child: const GovernancePage(),
      ),
    );
  }

  testWidgets('renders loading indicator when status is loading', (tester) async {
    when(() => mockCubit.state).thenReturn(const GovernanceState(status: GovernanceStatus.loading));
    when(() => mockCubit.loadProposals()).thenAnswer((_) async => {});

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('renders empty message when no proposals', (tester) async {
    when(() => mockCubit.state).thenReturn(const GovernanceState(status: GovernanceStatus.loaded, proposals: []));
    when(() => mockCubit.loadProposals()).thenAnswer((_) async => {});

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('No proposals found.'), findsOneWidget);
  });

  testWidgets('renders list of proposals', (tester) async {
    final proposals = [
      Proposal(
        id: '1',
        title: 'P1',
        description: 'D1',
        voteCount: 0,
        deadline: DateTime.now(),
        status: ProposalStatus.active,
      ),
    ];
    when(() => mockCubit.state).thenReturn(GovernanceState(status: GovernanceStatus.loaded, proposals: proposals));
    when(() => mockCubit.loadProposals()).thenAnswer((_) async => {});

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.byType(ProposalCard), findsOneWidget);
    expect(find.text('P1'), findsOneWidget);
  });
}
