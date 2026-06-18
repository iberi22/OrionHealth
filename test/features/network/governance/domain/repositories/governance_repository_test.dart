import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/network/governance/domain/entities/proposal.dart';
import 'package:orionhealth_health/features/network/governance/domain/entities/vote.dart';
import 'package:orionhealth_health/features/network/governance/domain/repositories/governance_repository.dart';

class MockGovernanceRepository extends Mock implements GovernanceRepository {}

void main() {
  late MockGovernanceRepository mockRepository;
  final baseDateTime = DateTime(2026, 7, 1);

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
      voter: 'v1',
      decision: VoteDecision.forProposal,
      weight: 1.0,
    ));
  });

  setUp(() {
    mockRepository = MockGovernanceRepository();
  });

  group('GovernanceRepository (domain contract)', () {
    test('getProposals returns a list of proposals', () async {
      final proposals = [
        Proposal(
          id: '1',
          title: 'Proposal 1',
          description: 'Desc 1',
          voteCount: 5,
          deadline: baseDateTime,
          status: ProposalStatus.active,
        ),
      ];

      when(() => mockRepository.getProposals()).thenAnswer((_) async => proposals);

      final result = await mockRepository.getProposals();
      expect(result, hasLength(1));
      expect(result.first.title, equals('Proposal 1'));
    });

    test('getProposals returns empty list when no proposals', () async {
      when(() => mockRepository.getProposals()).thenAnswer((_) async => []);

      final result = await mockRepository.getProposals();
      expect(result, isEmpty);
    });

    test('getProposalById returns a proposal when found', () async {
      final proposal = Proposal(
        id: '1',
        title: 'Test Proposal',
        description: 'Test',
        voteCount: 0,
        deadline: baseDateTime,
        status: ProposalStatus.active,
      );

      when(() => mockRepository.getProposalById('1')).thenAnswer((_) async => proposal);

      final result = await mockRepository.getProposalById('1');
      expect(result, isNotNull);
      expect(result!.id, equals('1'));
    });

    test('getProposalById returns null when not found', () async {
      when(() => mockRepository.getProposalById('non-existent')).thenAnswer((_) async => null);

      final result = await mockRepository.getProposalById('non-existent');
      expect(result, isNull);
    });

    test('createProposal calls repository successfully', () async {
      final proposal = Proposal(
        id: '1',
        title: 'New Proposal',
        description: 'New desc',
        voteCount: 0,
        deadline: baseDateTime,
        status: ProposalStatus.active,
      );

      when(() => mockRepository.createProposal(any())).thenAnswer((_) async => {});

      await mockRepository.createProposal(proposal);
      verify(() => mockRepository.createProposal(proposal)).called(1);
    });

    test('vote records a vote correctly', () async {
      final vote = Vote(
        proposalId: '1',
        voter: 'user-123',
        decision: VoteDecision.forProposal,
        weight: 1.0,
      );

      when(() => mockRepository.vote(any())).thenAnswer((_) async => {});

      await mockRepository.vote(vote);
      verify(() => mockRepository.vote(vote)).called(1);
    });

    test('getVotesForProposal returns votes for a proposal', () async {
      final votes = [
        Vote(
          proposalId: '1',
          voter: 'user-123',
          decision: VoteDecision.forProposal,
          weight: 1.0,
        ),
      ];

      when(() => mockRepository.getVotesForProposal('1')).thenAnswer((_) async => votes);

      final result = await mockRepository.getVotesForProposal('1');
      expect(result, hasLength(1));
      expect(result.first.voter, equals('user-123'));
    });

    test('updateProposalStatus updates proposal status', () async {
      when(() => mockRepository.updateProposalStatus('1', ProposalStatus.passed))
          .thenAnswer((_) async => {});

      await mockRepository.updateProposalStatus('1', ProposalStatus.passed);
      verify(() => mockRepository.updateProposalStatus('1', ProposalStatus.passed)).called(1);
    });

    test('all methods are defined in the abstract class', () {
      // Verifies the mock can respond to all abstract methods
      expect(mockRepository, isA<GovernanceRepository>());
    });
  });
}
