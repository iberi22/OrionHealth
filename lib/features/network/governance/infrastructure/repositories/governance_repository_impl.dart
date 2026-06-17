import 'package:injectable/injectable.dart';
import '../../domain/entities/proposal.dart';
import '../../domain/entities/vote.dart';
import '../../domain/repositories/governance_repository.dart';
import '../datasources/governance_ipfs_datasource.dart';

@LazySingleton(as: GovernanceRepository)
class GovernanceRepositoryImpl implements GovernanceRepository {
  final GovernanceIpfsDatasource _ipfsDatasource;

  // In a real scenario, these would be persisted in local DB (e.g. Isar)
  // or discovered via an IPFS index/directory.
  final Map<String, String> _proposalIdToCid = {};
  final Map<String, List<String>> _proposalIdToVoteCids = {};

  GovernanceRepositoryImpl(this._ipfsDatasource);

  @override
  Future<void> createProposal(Proposal proposal) async {
    final cid = await _ipfsDatasource.uploadProposal(proposal);
    _proposalIdToCid[proposal.id] = cid;
  }

  @override
  Future<List<Proposal>> getProposals() async {
    final proposals = await Future.wait(
      _proposalIdToCid.values.map((cid) => _ipfsDatasource.fetchProposal(cid)),
    );
    return proposals.toList();
  }

  @override
  Future<Proposal?> getProposalById(String id) async {
    final cid = _proposalIdToCid[id];
    if (cid == null) return null;
    return await _ipfsDatasource.fetchProposal(cid);
  }

  @override
  Future<void> vote(Vote vote) async {
    final cid = await _ipfsDatasource.uploadVote(vote);
    _proposalIdToVoteCids.putIfAbsent(vote.proposalId, () => []).add(cid);
  }

  @override
  Future<List<Vote>> getVotesForProposal(String proposalId) async {
    final cids = _proposalIdToVoteCids[proposalId] ?? [];
    final votes = await Future.wait(
      cids.map((cid) => _ipfsDatasource.fetchVote(cid)),
    );
    return votes.toList();
  }

  @override
  Future<void> updateProposalStatus(String proposalId, ProposalStatus status) async {
    final proposal = await getProposalById(proposalId);
    if (proposal != null) {
      final updatedProposal = proposal.copyWith(status: status);
      final cid = await _ipfsDatasource.uploadProposal(updatedProposal);
      _proposalIdToCid[proposalId] = cid;
    }
  }
}
