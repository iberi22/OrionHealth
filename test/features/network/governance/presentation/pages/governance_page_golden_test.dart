import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orionhealth_health/core/di/injection.dart';
import 'package:orionhealth_health/features/network/governance/application/governance_cubit.dart';
import 'package:orionhealth_health/features/network/governance/domain/entities/proposal.dart';
import 'package:orionhealth_health/features/network/governance/presentation/pages/governance_page.dart';
import '../../../../../core/golden_test_utils.dart';

class MockGovernanceCubit extends Mock implements GovernanceCubit {}

void main() {
  late MockGovernanceCubit mockCubit;

  setUpAll(() {
    getIt.allowReassignment = true;
  });

  setUp(() {
    mockCubit = MockGovernanceCubit();
    when(() => mockCubit.loadProposals()).thenAnswer((_) async {});
    when(() => mockCubit.close()).thenAnswer((_) async {});
    when(() => mockCubit.stream).thenAnswer((_) => const Stream<GovernanceState>.empty());
  });

  group('GovernancePage Golden Tests', () {
    testWidgets('Loaded state', (tester) async {
      final proposals = [
        Proposal(
          id: '1',
          title: 'Upgrade Network',
          description: 'Proposal to upgrade the network to v2',
          voteCount: 150,
          deadline: DateTime(2025, 12, 31),
          status: ProposalStatus.active,
        ),
      ];

      when(() => mockCubit.state).thenReturn(GovernanceState(
        status: GovernanceStatus.loaded,
        proposals: proposals,
      ));

      setupGoldenTest(tester);
      await tester.pumpWidget(wrapWithMaterial(
        BlocProvider<GovernanceCubit>.value(
          value: mockCubit,
          child: const GovernancePage(),
        ),
      ));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(GovernancePage),
        matchesGoldenFile("goldens/governance_page_loaded.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('Empty state', (tester) async {
      when(() => mockCubit.state).thenReturn(const GovernanceState(
        status: GovernanceStatus.loaded,
        proposals: [],
      ));

      setupGoldenTest(tester);
      await tester.pumpWidget(wrapWithMaterial(
        BlocProvider<GovernanceCubit>.value(
          value: mockCubit,
          child: const GovernancePage(),
        ),
      ));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(GovernancePage),
        matchesGoldenFile("goldens/governance_page_empty.png"),
      );
      resetGoldenTest(tester);
    });
  });
}
