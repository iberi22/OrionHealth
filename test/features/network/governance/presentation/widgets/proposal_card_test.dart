import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/network/governance/domain/entities/proposal.dart';
import 'package:orionhealth_health/features/network/governance/presentation/widgets/proposal_card.dart';

void main() {
  final proposal = Proposal(
    id: '1',
    title: 'Test Proposal',
    description: 'This is a test description',
    voteCount: 42,
    deadline: DateTime(2026, 12, 31),
    status: ProposalStatus.active,
  );

  testWidgets('ProposalCard displays proposal information', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProposalCard(proposal: proposal),
        ),
      ),
    );

    expect(find.text('Test Proposal'), findsOneWidget);
    expect(find.text('This is a test description'), findsOneWidget);
    expect(find.text('Votes: 42'), findsOneWidget);
    expect(find.text('ACTIVE'), findsOneWidget);
  });

  testWidgets('ProposalCard calls onTap when pressed', (WidgetTester tester) async {
    bool tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProposalCard(
            proposal: proposal,
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(ProposalCard));
    expect(tapped, true);
  });
}
