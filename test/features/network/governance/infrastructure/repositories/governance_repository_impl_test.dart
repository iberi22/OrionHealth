import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/network/governance/domain/entities/proposal.dart';
import 'package:orionhealth_health/features/network/governance/domain/entities/vote.dart';
import 'package:orionhealth_health/features/network/governance/infrastructure/datasources/governance_ipfs_datasource.dart';
import 'package:orionhealth_health/features/network/governance/infrastructure/repositories/governance_repository_impl.dart';

class MockGovernanceIpfsDatasource extends Mock implements GovernanceIpfsDatasource {}

void main() {
  late GovernanceRepositoryImpl repository;
  late MockGovernanceIpfsDatasource mockIpfsDatasource;

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
  });

  setUp(() {
    mockIpfsDatasource = MockGovernanceIpfsDatasource();
    repository = GovernanceRepositoryImpl(mockIpfsDatasource);
  });

  group('GovernanceRepositoryImpl', () {
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

    test('createProposal uploads to IPFS', () async {
      when(() => mockIpfsDatasource.uploadProposal(any())).thenAnswer((_) async => 'Qm123');

      await repository.createProposal(proposal);

      verify(() => mockIpfsDatasource.uploadProposal(proposal)).called(1);
    });

    test('getProposals fetches from IPFS', () async {
      when(() => mockIpfsDatasource.uploadProposal(any())).thenAnswer((_) async => 'Qm123');
      when(() => mockIpfsDatasource.fetchProposal('Qm123')).thenAnswer((_) async => proposal);

      await repository.createProposal(proposal);
      final result = await repository.getProposals();

      expect(result.length, 1);
      expect(result.first, proposal);
    });

    test('getProposalById fetches from IPFS', () async {
      when(() => mockIpfsDatasource.uploadProposal(any())).thenAnswer((_) async => 'Qm123');
      when(() => mockIpfsDatasource.fetchProposal('Qm123')).thenAnswer((_) async => proposal);

      await repository.createProposal(proposal);
      final result = await repository.getProposalById('1');

      expect(result, proposal);
    });

    test('vote uploads to IPFS', () async {
      when(() => mockIpfsDatasource.uploadVote(any())).thenAnswer((_) async => 'QmVote');

      await repository.vote(vote);

      verify(() => mockIpfsDatasource.uploadVote(vote)).called(1);
    });

    test('getVotesForProposal fetches from IPFS', () async {
      when(() => mockIpfsDatasource.uploadVote(any())).thenAnswer((_) async => 'QmVote');
      when(() => mockIpfsDatasource.fetchVote('QmVote')).thenAnswer((_) async => vote);

      await repository.vote(vote);
      final result = await repository.getVotesForProposal('1');

      expect(result.length, 1);
      expect(result.first, vote);
    });

    test('updateProposalStatus uploads updated proposal', () async {
      when(() => mockIpfsDatasource.uploadProposal(any())).thenAnswer((_) async => 'Qm123');
      when(() => mockIpfsDatasource.fetchProposal('Qm123')).thenAnswer((_) async => proposal);

      await repository.createProposal(proposal);

      final updatedProposal = proposal.copyWith(status: ProposalStatus.passed);
      when(() => mockIpfsDatasource.uploadProposal(updatedProposal)).thenAnswer((_) async => 'Qm456');

      await repository.updateProposalStatus('1', ProposalStatus.passed);

      verify(() => mockIpfsDatasource.uploadProposal(updatedProposal)).called(1);
    });

    test('getProposalById returns null if not found in memory map', () async {
      final result = await repository.getProposalById('non-existent');
      expect(result, isNull);
    });

    test('getVotesForProposal returns empty list if no votes for proposal', () async {
      final result = await repository.getVotesForProposal('no-votes');
      expect(result, isEmpty);
    });

    test('updateProposalStatus does nothing if proposal not found', () async {
      await repository.updateProposalStatus('non-existent', ProposalStatus.passed);
      verifyNever(() => mockIpfsDatasource.uploadProposal(any()));
    });
  });
}
