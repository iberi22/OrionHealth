import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:orionhealth_health/features/network/governance/presentation/pages/governance_page.dart';
import 'package:orionhealth_health/features/network/governance/application/governance_cubit.dart';
import 'package:orionhealth_health/features/network/governance/domain/entities/proposal.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'utils/video_recorder.dart';

class MockGovernanceCubit extends Mock implements GovernanceCubit {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockGovernanceCubit mockCubit;

  setUp(() {
    mockCubit = MockGovernanceCubit();
    when(() => mockCubit.loadProposals()).thenAnswer((_) async {});
    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
  });

  group('Governance Flow - E2E Tests', () {
    testWidgets('E2E: List Proposals', (WidgetTester tester) async {
      final proposals = [
        Proposal(
          id: '1',
          title: 'Upgrade P2P Protocol',
          description: 'Improve security',
          authorId: 'user1',
          createdAt: DateTime.now(),
          status: ProposalStatus.active,
          yesVotes: 10,
          noVotes: 2,
        ),
      ];

      when(() => mockCubit.state).thenReturn(GovernanceState(
        status: GovernanceStatus.loaded,
        proposals: proposals,
      ));

      await tester.pumpWidget(MaterialApp(
        home: BlocProvider<GovernanceCubit>.value(
          value: mockCubit,
          child: const GovernancePage(),
        ),
      ));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'governance', '01_list');

      expect(find.text('Upgrade P2P Protocol'), findsOneWidget);
    });
  });
}
