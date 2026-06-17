import 'package:equatable/equatable.dart';

enum VoteDecision {
  forProposal,
  againstProposal,
  abstain,
}

class Vote extends Equatable {
  final String proposalId;
  final String voter;
  final VoteDecision decision;
  final double weight;

  const Vote({
    required this.proposalId,
    required this.voter,
    required this.decision,
    required this.weight,
  });

  @override
  List<Object?> get props => [proposalId, voter, decision, weight];
}
