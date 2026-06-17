import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import '../domain/entities/proposal.dart';
import '../domain/entities/vote.dart';
import '../domain/repositories/governance_repository.dart';

enum GovernanceStatus { initial, loading, loaded, error }

class GovernanceState extends Equatable {
  final List<Proposal> proposals;
  final GovernanceStatus status;
  final String? errorMessage;

  const GovernanceState({
    this.proposals = const [],
    this.status = GovernanceStatus.initial,
    this.errorMessage,
  });

  GovernanceState copyWith({
    List<Proposal>? proposals,
    GovernanceStatus? status,
    String? errorMessage,
  }) {
    return GovernanceState(
      proposals: proposals ?? this.proposals,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [proposals, status, errorMessage];
}

class GovernanceCubit extends Cubit<GovernanceState> {
  final GovernanceRepository _repository;
  final _uuid = const Uuid();

  GovernanceCubit(this._repository) : super(const GovernanceState());

  Future<void> loadProposals() async {
    emit(state.copyWith(status: GovernanceStatus.loading));
    try {
      final proposals = await _repository.getProposals();
      emit(state.copyWith(status: GovernanceStatus.loaded, proposals: proposals));
    } catch (e) {
      emit(state.copyWith(status: GovernanceStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> createProposal(String title, String description, Duration duration) async {
    final proposal = Proposal(
      id: _uuid.v4(),
      title: title,
      description: description,
      voteCount: 0,
      deadline: DateTime.now().add(duration),
      status: ProposalStatus.active,
    );

    try {
      await _repository.createProposal(proposal);
      await loadProposals();
    } catch (e) {
      emit(state.copyWith(status: GovernanceStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> vote(String proposalId, String voter, VoteDecision decision, double weight) async {
    final vote = Vote(
      proposalId: proposalId,
      voter: voter,
      decision: decision,
      weight: weight,
    );

    try {
      await _repository.vote(vote);
      await loadProposals();
    } catch (e) {
      emit(state.copyWith(status: GovernanceStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> tally(String proposalId) async {
    try {
      final proposal = await _repository.getProposalById(proposalId);
      if (proposal == null) return;

      if (DateTime.now().isBefore(proposal.deadline)) {
        // Option: allow tallying before deadline if desired, or strictly after.
        // For expansion system, let's assume we can tally at any time to see current results,
        // but status change only after deadline or certain threshold.
      }

      final votes = await _repository.getVotesForProposal(proposalId);
      double forVotes = 0;
      double againstVotes = 0;

      for (var vote in votes) {
        if (vote.decision == VoteDecision.forProposal) {
          forVotes += vote.weight;
        } else if (vote.decision == VoteDecision.againstProposal) {
          againstVotes += vote.weight;
        }
      }

      ProposalStatus newStatus = proposal.status;
      if (DateTime.now().isAfter(proposal.deadline)) {
        newStatus = forVotes > againstVotes ? ProposalStatus.passed : ProposalStatus.rejected;
      }

      await _repository.updateProposalStatus(proposalId, newStatus);
      await loadProposals();
    } catch (e) {
      emit(state.copyWith(status: GovernanceStatus.error, errorMessage: e.toString()));
    }
  }
}
