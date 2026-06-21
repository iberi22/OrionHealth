import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/network/governance/domain/entities/proposal.dart';
import 'package:orionhealth_health/features/network/governance/domain/entities/vote.dart';
import 'package:orionhealth_health/features/network/governance/domain/repositories/governance_repository.dart';

class MockGovernanceRepository extends Mock implements GovernanceRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(Proposal(
      id: 'fake',
      title: '',
      description: '',
      voteCount: 0,
      deadline: DateTime.now(),
      status: ProposalStatus.active,
    ));
    registerFallbackValue(const Vote(
      proposalId: 'fake',
      voter: '',
      decision: VoteDecision.abstain,
      weight: 0,
    ));
    registerFallbackValue(ProposalStatus.active);
  });

  late MockGovernanceRepository repository;

  setUp(() {
    repository = MockGovernanceRepository();
  });

  group('GovernanceRepository', () {
    final proposal = Proposal(
      id: '1',
      title: 'Test',
      description: 'Desc',
      voteCount: 0,
      deadline: DateTime(2026, 1, 1),
      status: ProposalStatus.active,
    );

    final vote = const Vote(
      proposalId: '1',
      voter: 'voter1',
      decision: VoteDecision.forProposal,
      weight: 1.0,
    );

    test('getProposals should return a list of proposals', () async {
      when(() => repository.getProposals()).thenAnswer((_) async => [proposal]);

      final result = await repository.getProposals();

      expect(result, [proposal]);
      verify(() => repository.getProposals()).called(1);
    });

    test('getProposalById should return a proposal when it exists', () async {
      when(() => repository.getProposalById('1')).thenAnswer((_) async => proposal);

      final result = await repository.getProposalById('1');

      expect(result, proposal);
      verify(() => repository.getProposalById('1')).called(1);
    });

    test('createProposal should complete', () async {
      when(() => repository.createProposal(any())).thenAnswer((_) async => {});

      await repository.createProposal(proposal);

      verify(() => repository.createProposal(proposal)).called(1);
    });

    test('vote should complete', () async {
      when(() => repository.vote(any())).thenAnswer((_) async => {});

      await repository.vote(vote);

      verify(() => repository.vote(vote)).called(1);
    });

    test('getVotesForProposal should return a list of votes', () async {
      when(() => repository.getVotesForProposal('1')).thenAnswer((_) async => [vote]);

      final result = await repository.getVotesForProposal('1');

      expect(result, [vote]);
      verify(() => repository.getVotesForProposal('1')).called(1);
    });

    test('updateProposalStatus should complete', () async {
      when(() => repository.updateProposalStatus(any(), any())).thenAnswer((_) async => {});

      await repository.updateProposalStatus('1', ProposalStatus.passed);

      verify(() => repository.updateProposalStatus('1', ProposalStatus.passed)).called(1);
    });
  });

}
