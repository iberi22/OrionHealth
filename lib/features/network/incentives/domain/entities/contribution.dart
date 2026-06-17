import 'package:equatable/equatable.dart';

enum ContributionType {
  storage,
  dataSharing,
  validation,
}

class Contribution extends Equatable {
  final String id;
  final String userId;
  final ContributionType type;
  final int rewardPoints;
  final DateTime timestamp;

  const Contribution({
    required this.id,
    required this.userId,
    required this.type,
    required this.rewardPoints,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [id, userId, type, rewardPoints, timestamp];
}
