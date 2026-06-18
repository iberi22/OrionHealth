import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/network/governance/application/governance_cubit.dart';
import 'package:orionhealth_health/features/network/governance/domain/entities/proposal.dart';
import 'package:orionhealth_health/features/network/governance/presentation/pages/governance_page.dart';

class MockGovernanceCubit extends Mock implements GovernanceCubit {}

void main() {
  late MockGovernanceCubit mockCubit;

  setUp(() {
    mockCubit = MockGovernanceCubit();
    when(() => mockCubit.loadProposals()).thenAnswer((_) async {});
    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockCubit.close()).thenAnswer((_) async {});
  });

  testWidgets('GovernancePage golden test', (WidgetTester tester) async {
    final proposals = [
      Proposal(
        id: '1',
        title: 'Upgrade Network Protocol',
        description: 'Proposal to upgrade the network protocol to version 2.0 for better efficiency.',
        voteCount: 150,
        deadline: DateTime(2026, 12, 31),
        status: ProposalStatus.active,
      ),
      Proposal(
        id: '2',
        title: 'Community Fund Allocation',
        description: 'Allocate 5000 tokens for community health initiatives.',
        voteCount: 85,
        deadline: DateTime(2026, 11, 15),
        status: ProposalStatus.passed,
      ),
      Proposal(
        id: '3',
        title: 'New Validator Requirements',
        description: 'Increase the minimum stake required for validators.',
        voteCount: 42,
        deadline: DateTime(2026, 10, 1),
        status: ProposalStatus.rejected,
      ),
    ];

    when(() => mockCubit.state).thenReturn(
      GovernanceState(status: GovernanceStatus.loaded, proposals: proposals),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        home: BlocProvider<GovernanceCubit>.value(
          value: mockCubit,
          child: const GovernancePage(),
        ),
      ),
    );

    await expectLater(
      find.byType(GovernancePage),
      matchesGoldenFile('goldens/governance_page.png'),
    );
  });
}
