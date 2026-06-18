import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/network/governance/domain/entities/proposal.dart';
import 'package:orionhealth_health/features/network/governance/domain/entities/vote.dart';
import 'package:orionhealth_health/features/network/governance/presentation/widgets/vote_widget.dart';

void main() {
  final activeProposal = Proposal(
    id: '1',
    title: 'Active',
    description: 'Desc',
    voteCount: 0,
    deadline: DateTime.now().add(const Duration(days: 1)),
    status: ProposalStatus.active,
  );

  final closedProposal = Proposal(
    id: '2',
    title: 'Closed',
    description: 'Desc',
    voteCount: 10,
    deadline: DateTime.now().subtract(const Duration(days: 1)),
    status: ProposalStatus.passed,
  );

  testWidgets('VoteWidget allows selecting and submitting a vote', (WidgetTester tester) async {
    VoteDecision? selectedDecision;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: VoteWidget(
          proposal: activeProposal,
          onVote: (d) => selectedDecision = d,
        ),
      ),
    ));

    expect(find.text('Cast your vote'), findsOneWidget);
    expect(find.text('FOR'), findsOneWidget);
    expect(find.text('AGAINST'), findsOneWidget);
    expect(find.text('ABSTAIN'), findsOneWidget);

    final submitButtonFinder = find.text('SUBMIT VOTE');
    expect(tester.widget<ElevatedButton>(find.byType(ElevatedButton)).enabled, isFalse);

    await tester.tap(find.text('FOR'));
    await tester.pump();
    expect(tester.widget<ElevatedButton>(find.byType(ElevatedButton)).enabled, isTrue);

    await tester.tap(submitButtonFinder);
    expect(selectedDecision, equals(VoteDecision.forProposal));
  });

  testWidgets('VoteWidget shows closed message for inactive proposals', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: VoteWidget(
          proposal: closedProposal,
          onVote: (_) {},
        ),
      ),
    ));

    expect(find.text('Voting is closed for this proposal'), findsOneWidget);
    expect(find.text('FOR'), findsNothing);
  });
}
