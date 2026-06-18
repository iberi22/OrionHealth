import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/network/governance/domain/entities/proposal.dart';
import 'package:orionhealth_health/features/network/governance/presentation/widgets/governance_dashboard.dart';
import 'package:orionhealth_health/core/widgets/glassmorphic_card.dart';

void main() {
  final proposals = [
    Proposal(
      id: '1',
      title: 'P1',
      description: 'D1',
      voteCount: 10,
      deadline: DateTime.now(),
      status: ProposalStatus.active,
    ),
    Proposal(
      id: '2',
      title: 'P2',
      description: 'D2',
      voteCount: 20,
      deadline: DateTime.now(),
      status: ProposalStatus.passed,
    ),
  ];

  testWidgets('GovernanceDashboard displays correct stats', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: GovernanceDashboard(proposals: proposals),
      ),
    ));

    expect(find.text('Active'), findsOneWidget);
    expect(find.text('Passed'), findsOneWidget);
    expect(find.text('Total Proposals'), findsOneWidget);
    expect(find.text('Total Votes'), findsOneWidget);

    expect(find.text('1'), findsNWidgets(2)); // Active: 1, Passed: 1 (Wait, 1 active, 1 passed, 2 total, 30 votes)
    expect(find.text('2'), findsOneWidget); // Total Proposals: 2
    expect(find.text('30'), findsOneWidget); // Total Votes: 30

    expect(find.byType(GlassmorphicCard), findsNWidgets(4));
  });

  testWidgets('GovernanceDashboard handles empty proposals', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: GovernanceDashboard(proposals: []),
      ),
    ));

    expect(find.text('0'), findsNWidgets(4));
  });
}
