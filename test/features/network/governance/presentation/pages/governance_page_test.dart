import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/network/governance/application/governance_cubit.dart';
import 'package:orionhealth_health/features/network/governance/domain/entities/proposal.dart';
import 'package:orionhealth_health/features/network/governance/domain/entities/vote.dart';
import 'package:orionhealth_health/features/network/governance/presentation/pages/governance_page.dart';
import 'package:orionhealth_health/features/network/governance/presentation/widgets/governance_dashboard.dart';
import 'package:orionhealth_health/features/network/governance/presentation/widgets/proposal_list_widget.dart';
import 'package:orionhealth_health/features/network/governance/presentation/widgets/vote_widget.dart';

class MockGovernanceCubit extends Mock implements GovernanceCubit {}

void main() {
  late MockGovernanceCubit mockCubit;

  setUpAll(() {
    registerFallbackValue(const Duration(days: 1));
    registerFallbackValue(VoteDecision.forProposal);
  });

  setUp(() {
    mockCubit = MockGovernanceCubit();
    when(() => mockCubit.state).thenReturn(const GovernanceState());
    when(() => mockCubit.loadProposals()).thenAnswer((_) async {});
    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockCubit.close()).thenAnswer((_) async {});
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<GovernanceCubit>.value(
        value: mockCubit,
        child: const GovernancePage(),
      ),
    );
  }

  testWidgets('GovernancePage displays loading indicator when loading', (WidgetTester tester) async {
    when(() => mockCubit.state).thenReturn(
      const GovernanceState(status: GovernanceStatus.loading),
    );

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('GovernancePage displays dashboard and list when loaded', (WidgetTester tester) async {
    final proposals = [
      Proposal(
        id: '1',
        title: 'Proposal 1',
        description: 'Desc 1',
        voteCount: 5,
        deadline: DateTime.now(),
        status: ProposalStatus.active,
      ),
    ];

    when(() => mockCubit.state).thenReturn(
      GovernanceState(status: GovernanceStatus.loaded, proposals: proposals),
    );

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.byType(GovernanceDashboard), findsOneWidget);
    expect(find.byType(ProposalListWidget), findsOneWidget);
    expect(find.text('Proposal 1'), findsOneWidget);
  });

  testWidgets('GovernancePage shows error snackbar on error', (WidgetTester tester) async {
    final states = [
      const GovernanceState(status: GovernanceStatus.initial),
      const GovernanceState(status: GovernanceStatus.error, errorMessage: 'Error occurred'),
    ];

    when(() => mockCubit.state).thenReturn(states[0]);
    when(() => mockCubit.stream).thenAnswer((_) => Stream.fromIterable([states[1]]));

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump(); // Trigger listener

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Error occurred'), findsOneWidget);
  });

  testWidgets('GovernancePage calls loadProposals on refresh', (WidgetTester tester) async {
    when(() => mockCubit.state).thenReturn(
      const GovernanceState(status: GovernanceStatus.loaded, proposals: []),
    );
    when(() => mockCubit.loadProposals()).thenAnswer((_) async {});

    await tester.pumpWidget(createWidgetUnderTest());

    await tester.fling(find.byType(RefreshIndicator), const Offset(0, 300), 1000);
    await tester.pumpAndSettle();

    verify(() => mockCubit.loadProposals()).called(1);
  });

  testWidgets('GovernancePage opens details and votes', (WidgetTester tester) async {
    final proposal = Proposal(
      id: '1',
      title: 'Proposal 1',
      description: 'Desc 1',
      voteCount: 5,
      deadline: DateTime.now().add(const Duration(days: 1)),
      status: ProposalStatus.active,
    );

    when(() => mockCubit.state).thenReturn(
      GovernanceState(status: GovernanceStatus.loaded, proposals: [proposal]),
    );
    when(() => mockCubit.vote(any(), any(), any(), any())).thenAnswer((_) async {});

    await tester.pumpWidget(createWidgetUnderTest());

    await tester.ensureVisible(find.text('Proposal 1'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Proposal 1'));
    await tester.pumpAndSettle();

    expect(find.text('Desc 1'), findsOneWidget);
    expect(find.byType(VoteWidget), findsOneWidget);

    await tester.tap(find.text('FOR'));
    await tester.pump();
    await tester.tap(find.text('SUBMIT VOTE'));
    await tester.pumpAndSettle();

    verify(() => mockCubit.vote('1', any(), VoteDecision.forProposal, 1.0)).called(1);
    expect(find.byType(DraggableScrollableSheet), findsNothing);
  });

  testWidgets('GovernancePage shows tally button when expired', (WidgetTester tester) async {
    final proposal = Proposal(
      id: '1',
      title: 'Expired',
      description: 'Desc 1',
      voteCount: 5,
      deadline: DateTime.now().subtract(const Duration(days: 1)),
      status: ProposalStatus.active,
    );

    when(() => mockCubit.state).thenReturn(
      GovernanceState(status: GovernanceStatus.loaded, proposals: [proposal]),
    );
    when(() => mockCubit.tally(any())).thenAnswer((_) async {});

    await tester.pumpWidget(createWidgetUnderTest());

    await tester.ensureVisible(find.text('Expired'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Expired'));
    await tester.pumpAndSettle();

    expect(find.text('TALLY VOTES'), findsOneWidget);
    await tester.tap(find.text('TALLY VOTES'));
    await tester.pumpAndSettle();

    verify(() => mockCubit.tally('1')).called(1);
  });

  testWidgets('GovernancePage opens create dialog and creates proposal', (WidgetTester tester) async {
    when(() => mockCubit.state).thenReturn(
      const GovernanceState(status: GovernanceStatus.loaded, proposals: []),
    );
    when(() => mockCubit.createProposal(any(), any(), any())).thenAnswer((_) async {});

    await tester.pumpWidget(createWidgetUnderTest());

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextField, 'Title'), 'New Proposal');
    await tester.enterText(find.widgetWithText(TextField, 'Description'), 'New Desc');
    await tester.tap(find.text('CREATE'));
    await tester.pumpAndSettle();

    verify(() => mockCubit.createProposal('New Proposal', 'New Desc', any())).called(1);
  });
}
