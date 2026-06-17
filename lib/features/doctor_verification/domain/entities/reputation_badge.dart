import 'package:isar/isar.dart';

part 'reputation_badge.g.dart';

enum BadgeLevel { bronze, silver, gold, platinum }

@collection
class ReputationBadge {
  Id isarId = Isar.autoIncrement;

  final String id;
  final String doctorId;

  @enumerated
  final BadgeLevel level;

  final String criteria;
  final DateTime earnedDate;

  ReputationBadge({
    required this.id,
    required this.doctorId,
    required this.level,
    required this.criteria,
    required this.earnedDate,
  });
}
