import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/network/governance/domain/entities/proposal.dart';
import 'package:orionhealth_health/features/network/governance/presentation/widgets/proposal_list_widget.dart';
import 'package:orionhealth_health/core/widgets/glassmorphic_card.dart';

void main() {
  final proposals = [
    Proposal(
      id: '1',
      title: 'Proposal One',
      description: 'Description One',
      voteCount: 10,
      deadline: DateTime(2026, 1, 1),
      status: ProposalStatus.active,
    ),
    Proposal(
      id: '2',
      title: 'Proposal Two',
      description: 'Description Two',
      voteCount: 20,
      deadline: DateTime(2026, 2, 1),
      status: ProposalStatus.passed,
    ),
  ];

  testWidgets('ProposalListWidget displays list of proposals', (WidgetTester tester) async {
    Proposal? tappedProposal;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: ProposalListWidget(
            proposals: proposals,
            onProposalTap: (p) => tappedProposal = p,
          ),
        ),
      ),
    ));

    expect(find.text('Proposal One'), findsOneWidget);
    expect(find.text('Proposal Two'), findsOneWidget);
    expect(find.text('Description One'), findsOneWidget);
    expect(find.text('Description Two'), findsOneWidget);
    expect(find.text('ACTIVE'), findsOneWidget);
    expect(find.text('PASSED'), findsOneWidget);
    expect(find.text('Votes: 10'), findsOneWidget);
    expect(find.text('Votes: 20'), findsOneWidget);

    await tester.tap(find.text('Proposal One'));
    expect(tappedProposal, equals(proposals[0]));
  });

  testWidgets('ProposalListWidget displays empty state', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ProposalListWidget(
          proposals: const [],
          onProposalTap: (_) {},
        ),
      ),
    ));

    expect(find.text('No proposals found'), findsOneWidget);
  });
}
