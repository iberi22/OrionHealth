import '../entities/proposal.dart';
import '../entities/vote.dart';

abstract class GovernanceRepository {
  Future<List<Proposal>> getProposals();
  Future<Proposal?> getProposalById(String id);
  Future<void> createProposal(Proposal proposal);
  Future<void> vote(Vote vote);
  Future<List<Vote>> getVotesForProposal(String proposalId);
  Future<void> updateProposalStatus(String proposalId, ProposalStatus status);
}
