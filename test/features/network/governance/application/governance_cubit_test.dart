import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/network/governance/application/governance_cubit.dart';
import 'package:orionhealth_health/features/network/governance/domain/entities/proposal.dart';
import 'package:orionhealth_health/features/network/governance/domain/entities/vote.dart';
import 'package:orionhealth_health/features/network/governance/domain/repositories/governance_repository.dart';

class MockGovernanceRepository extends Mock implements GovernanceRepository {}

void main() {
  late GovernanceCubit cubit;
  late MockGovernanceRepository repository;

  setUpAll(() {
    registerFallbackValue(Proposal(
      id: '1',
      title: 'Test',
      description: 'Desc',
      voteCount: 0,
      deadline: DateTime.now(),
      status: ProposalStatus.active,
    ));

    registerFallbackValue(const Vote(
      proposalId: '1',
      voter: 'voter1',
      decision: VoteDecision.forProposal,
      weight: 1.0,
    ));
  });

  setUp(() {
    repository = MockGovernanceRepository();
    cubit = GovernanceCubit(repository);
  });

  tearDown(() {
    cubit.close();
  });

  group('GovernanceCubit', () {
    test('initial state is correct', () {
      expect(cubit.state, const GovernanceState());
    });

    test('loadProposals updates status and proposals', () async {
      final proposals = [
        Proposal(
          id: '1',
          title: 'Proposal 1',
          description: 'Description 1',
          voteCount: 10,
          deadline: DateTime.now(),
          status: ProposalStatus.active,
        ),
      ];

      when(() => repository.getProposals()).thenAnswer((_) async => proposals);

      await cubit.loadProposals();

      expect(cubit.state.status, GovernanceStatus.loaded);
      expect(cubit.state.proposals, proposals);
    });

    test('createProposal calls repository and reloads', () async {
      when(() => repository.createProposal(any())).thenAnswer((_) async => {});
      when(() => repository.getProposals()).thenAnswer((_) async => []);

      await cubit.createProposal('Title', 'Desc', const Duration(days: 1));

      verify(() => repository.createProposal(any())).called(1);
      verify(() => repository.getProposals()).called(1);
    });

    test('vote calls repository and reloads', () async {
      when(() => repository.vote(any())).thenAnswer((_) async => {});
      when(() => repository.getProposals()).thenAnswer((_) async => []);

      await cubit.vote('prop1', 'voter1', VoteDecision.forProposal, 1.0);

      verify(() => repository.vote(any())).called(1);
      verify(() => repository.getProposals()).called(1);
    });

    test('tally updates status to passed if majority for', () async {
      final proposal = Proposal(
        id: '1',
        title: 'Title',
        description: 'Desc',
        voteCount: 0,
        deadline: DateTime.now().subtract(const Duration(hours: 1)),
        status: ProposalStatus.active,
      );

      final votes = [
        const Vote(proposalId: '1', voter: 'v1', decision: VoteDecision.forProposal, weight: 10.0),
        const Vote(proposalId: '1', voter: 'v2', decision: VoteDecision.againstProposal, weight: 5.0),
      ];

      when(() => repository.getProposalById('1')).thenAnswer((_) async => proposal);
      when(() => repository.getVotesForProposal('1')).thenAnswer((_) async => votes);
      when(() => repository.updateProposalStatus('1', ProposalStatus.passed)).thenAnswer((_) async => {});
      when(() => repository.getProposals()).thenAnswer((_) async => []);

      await cubit.tally('1');

      verify(() => repository.updateProposalStatus('1', ProposalStatus.passed)).called(1);
    });

    test('tally updates status to rejected if majority against', () async {
      final proposal = Proposal(
        id: '1',
        title: 'Title',
        description: 'Desc',
        voteCount: 0,
        deadline: DateTime.now().subtract(const Duration(hours: 1)),
        status: ProposalStatus.active,
      );

      final votes = [
        const Vote(proposalId: '1', voter: 'v1', decision: VoteDecision.forProposal, weight: 5.0),
        const Vote(proposalId: '1', voter: 'v2', decision: VoteDecision.againstProposal, weight: 10.0),
      ];

      when(() => repository.getProposalById('1')).thenAnswer((_) async => proposal);
      when(() => repository.getVotesForProposal('1')).thenAnswer((_) async => votes);
      when(() => repository.updateProposalStatus('1', ProposalStatus.rejected)).thenAnswer((_) async => {});
      when(() => repository.getProposals()).thenAnswer((_) async => []);

      await cubit.tally('1');

      verify(() => repository.updateProposalStatus('1', ProposalStatus.rejected)).called(1);
    });
  });
}
