import 'package:equatable/equatable.dart';

class Reward extends Equatable {
  final String id;
  final String userId;
  final int points;
  final String tier;
  final bool isClaimed;

  const Reward({
    required this.id,
    required this.userId,
    required this.points,
    required this.tier,
    required this.isClaimed,
  });

  Reward copyWith({
    String? id,
    String? userId,
    int? points,
    String? tier,
    bool? isClaimed,
  }) {
    return Reward(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      points: points ?? this.points,
      tier: tier ?? this.tier,
      isClaimed: isClaimed ?? this.isClaimed,
    );
  }

  @override
  List<Object?> get props => [id, userId, points, tier, isClaimed];
}
