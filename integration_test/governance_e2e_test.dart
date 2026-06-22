import 'dart:async';
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
  late StreamController<GovernanceState> stateController;

  setUp(() {
    mockCubit = MockGovernanceCubit();
    stateController = StreamController<GovernanceState>.broadcast();

    when(() => mockCubit.loadProposals()).thenAnswer((_) async {});
    when(() => mockCubit.stream).thenAnswer((_) => stateController.stream);
  });

  tearDown(() {
    stateController.close();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<GovernanceCubit>.value(
        value: mockCubit,
        child: const GovernancePage(),
      ),
    );
  }

  group('Governance Flow - E2E Tests', () {
    testWidgets('E2E: List Proposals', (WidgetTester tester) async {
      final proposals = [
        Proposal(
          id: '1',
          title: 'Upgrade P2P Protocol',
          description: 'Improve security',
          voteCount: 10,
          deadline: DateTime.now().add(const Duration(days: 7)),
          status: ProposalStatus.active,
        ),
      ];

      when(() => mockCubit.state).thenReturn(GovernanceState(
        status: GovernanceStatus.loaded,
        proposals: proposals,
      ));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'governance', '01_list');

      expect(find.text('Upgrade P2P Protocol'), findsOneWidget);
    });

    testWidgets('E2E: Proposal Submission Fails (Network)', (WidgetTester tester) async {
      when(() => mockCubit.state).thenReturn(const GovernanceState(
        status: GovernanceStatus.loaded,
        proposals: [],
      ));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'governance', '02_create_page');

      expect(find.text('Create Proposal'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField).first, 'Test Title');
      await tester.enterText(find.byType(TextFormField).last, 'Test Description');

      when(() => mockCubit.createProposal(any(), any(), any())).thenAnswer((_) async {
        final errorState = const GovernanceState(
          status: GovernanceStatus.error,
          errorMessage: 'Network connection failed',
        );
        when(() => mockCubit.state).thenReturn(errorState);
        stateController.add(errorState);
      });

      await tester.tap(find.text('Submit Proposal'));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'governance', '03_submit_error');

      expect(find.text('Error: Network connection failed'), findsOneWidget);
    });

    testWidgets('E2E: Voting Timeout', (WidgetTester tester) async {
      final proposal = Proposal(
        id: '1',
        title: 'Upgrade P2P Protocol',
        description: 'Improve security',
        voteCount: 10,
        deadline: DateTime.now().add(const Duration(days: 7)),
        status: ProposalStatus.active,
      );

      when(() => mockCubit.state).thenReturn(GovernanceState(
        status: GovernanceStatus.loaded,
        proposals: [proposal],
      ));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Upgrade P2P Protocol'));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'governance', '04_detail_page');

      when(() => mockCubit.vote(any(), any(), any(), any())).thenAnswer((_) async {
        final errorState = const GovernanceState(
          status: GovernanceStatus.error,
          errorMessage: 'Voting timed out',
        );
        when(() => mockCubit.state).thenReturn(errorState);
        stateController.add(errorState);
      });

      await tester.tap(find.text('For'));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'governance', '05_vote_error');

      expect(find.text('Error: Voting timed out'), findsOneWidget);
    });
  });
}
