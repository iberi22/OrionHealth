import 'package:equatable/equatable.dart';

enum ActivityType {
  vitalCheck,
  medicationTaken,
  reportGenerated,
  appointment,
  other
}

class ActivityItem extends Equatable {
  final String id;
  final String title;
  final DateTime timestamp;
  final ActivityType type;

  const ActivityItem({
    required this.id,
    required this.title,
    required this.timestamp,
    required this.type,
  });

  @override
  List<Object?> get props => [id, title, timestamp, type];
}
