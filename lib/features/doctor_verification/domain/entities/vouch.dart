import 'package:isar/isar.dart';

part 'vouch.g.dart';

@collection
class Vouch {
  Id isarId = Isar.autoIncrement;

  final String id;
  final String vouchedBy; // Doctor ID who is vouching
  final String targetDoctor; // Doctor ID being vouched for
  final String category; // e.g., 'Clinical Excellence', 'Ethics'
  final DateTime timestamp;

  Vouch({
    required this.id,
    required this.vouchedBy,
    required this.targetDoctor,
    required this.category,
    required this.timestamp,
  });
}
