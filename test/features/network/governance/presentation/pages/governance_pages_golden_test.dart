import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:orionhealth_health/features/network/governance/application/governance_cubit.dart';
import 'package:orionhealth_health/features/network/governance/domain/entities/proposal.dart';
import 'package:orionhealth_health/features/network/governance/presentation/pages/governance_page.dart';
import 'package:orionhealth_health/features/network/governance/presentation/pages/create_proposal_page.dart';
import 'package:orionhealth_health/features/network/governance/presentation/pages/proposal_detail_page.dart';
import 'package:orionhealth_health/features/network/governance/presentation/widgets/proposal_card.dart';
import '../../../../../core/golden_test_utils.dart';

class MockGovernanceCubit extends Mock implements GovernanceCubit {}

void main() {
  late MockGovernanceCubit mockCubit;

  setUp(() {
    mockCubit = MockGovernanceCubit();
    when(() => mockCubit.state).thenReturn(const GovernanceState());
    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockCubit.loadProposals()).thenAnswer((_) async {});
  });

  final testProposal = Proposal(
    id: '1',
    title: 'Mejorar seguridad de datos',
    description: 'Propuesta para implementar cifrado avanzado en la base de datos local.',
    deadline: DateTime(2025, 2, 1),
    status: ProposalStatus.active,
    voteCount: 12,
  );

  group('Governance Golden Tests', () {
    testWidgets('GovernancePage', (tester) async {
      setupGoldenTest(tester);
      when(() => mockCubit.state).thenReturn(GovernanceState(
        status: GovernanceStatus.loaded,
        proposals: [testProposal],
      ));

      await tester.pumpWidget(wrapWithMaterial(
        BlocProvider<GovernanceCubit>.value(
          value: mockCubit,
          child: const GovernancePage(),
        ),
      ));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(GovernancePage),
        matchesGoldenFile("../../../../../golden/reference/governance_page.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('CreateProposalPage', (tester) async {
      setupGoldenTest(tester);

      await tester.pumpWidget(wrapWithMaterial(
        BlocProvider<GovernanceCubit>.value(
          value: mockCubit,
          child: const CreateProposalPage(),
        ),
      ));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(CreateProposalPage),
        matchesGoldenFile("../../../../../golden/reference/create_proposal_page.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('ProposalDetailPage', (tester) async {
      setupGoldenTest(tester);
      tester.view.physicalSize = const Size(600, 1000);

      await tester.pumpWidget(wrapWithMaterial(
        BlocProvider<GovernanceCubit>.value(
          value: mockCubit,
          child: ProposalDetailPage(proposal: testProposal),
        ),
      ));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(ProposalDetailPage),
        matchesGoldenFile("../../../../../golden/reference/proposal_detail_page.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('ProposalCard', (tester) async {
      setupGoldenTest(tester);

      await tester.pumpWidget(wrapWithMaterial(
        Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ProposalCard(proposal: testProposal),
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(ProposalCard),
        matchesGoldenFile("../../../../../golden/reference/proposal_card.png"),
      );
      resetGoldenTest(tester);
    });
  });
}
