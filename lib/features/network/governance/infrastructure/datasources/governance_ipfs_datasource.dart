import 'dart:convert';
import 'dart:typed_data';
import 'package:injectable/injectable.dart';
import '../../../../sync/infrastructure/datasources/ipfs_datasource.dart';
import '../../domain/entities/proposal.dart';
import '../../domain/entities/vote.dart';

@lazySingleton
class GovernanceIpfsDatasource {
  final IpfsDatasource _ipfsDatasource;

  GovernanceIpfsDatasource(this._ipfsDatasource);

  /// Uploads a proposal to IPFS and returns its CID.
  Future<String> uploadProposal(Proposal proposal) async {
    final jsonMap = {
      'id': proposal.id,
      'title': proposal.title,
      'description': proposal.description,
      'voteCount': proposal.voteCount,
      'deadline': proposal.deadline.toIso8601String(),
      'status': proposal.status.name,
    };
    final jsonString = jsonEncode(jsonMap);
    final data = Uint8List.fromList(utf8.encode(jsonString));
    return await _ipfsDatasource.add(data);
  }

  /// Fetches a proposal from IPFS by its CID.
  Future<Proposal> fetchProposal(String cid) async {
    final data = await _ipfsDatasource.get(cid);
    final jsonString = utf8.decode(data);
    final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;

    return Proposal(
      id: jsonMap['id'] as String,
      title: jsonMap['title'] as String,
      description: jsonMap['description'] as String,
      voteCount: jsonMap['voteCount'] as int,
      deadline: DateTime.parse(jsonMap['deadline'] as String),
      status: ProposalStatus.values.byName(jsonMap['status'] as String),
    );
  }

  /// Uploads a vote to IPFS and returns its CID.
  Future<String> uploadVote(Vote vote) async {
    final jsonMap = {
      'proposalId': vote.proposalId,
      'voter': vote.voter,
      'decision': vote.decision.name,
      'weight': vote.weight,
    };
    final jsonString = jsonEncode(jsonMap);
    final data = Uint8List.fromList(utf8.encode(jsonString));
    return await _ipfsDatasource.add(data);
  }

  /// Fetches a vote from IPFS by its CID.
  Future<Vote> fetchVote(String cid) async {
    final data = await _ipfsDatasource.get(cid);
    final jsonString = utf8.decode(data);
    final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;

    return Vote(
      proposalId: jsonMap['proposalId'] as String,
      voter: jsonMap['voter'] as String,
      decision: VoteDecision.values.byName(jsonMap['decision'] as String),
      weight: (jsonMap['weight'] as num).toDouble(),
    );
  }
}
