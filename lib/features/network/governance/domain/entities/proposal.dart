import 'package:equatable/equatable.dart';

enum ProposalStatus {
  active,
  passed,
  rejected,
  expired,
}

class Proposal extends Equatable {
  final String id;
  final String title;
  final String description;
  final int voteCount;
  final DateTime deadline;
  final ProposalStatus status;

  const Proposal({
    required this.id,
    required this.title,
    required this.description,
    required this.voteCount,
    required this.deadline,
    required this.status,
  });

  Proposal copyWith({
    String? id,
    String? title,
    String? description,
    int? voteCount,
    DateTime? deadline,
    ProposalStatus? status,
  }) {
    return Proposal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      voteCount: voteCount ?? this.voteCount,
      deadline: deadline ?? this.deadline,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [id, title, description, voteCount, deadline, status];
}
