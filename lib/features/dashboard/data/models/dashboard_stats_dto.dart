import '../../domain/entities/dashboard_stats.dart';
import '../../domain/entities/activity_item.dart';

class DashboardStatsDto {
  final int totalMedications;
  final int reportsCount;
  final DateTime? lastVitalCheck;

  const DashboardStatsDto({
    required this.totalMedications, required this.reportsCount, this.lastVitalCheck,
  });

  DashboardStats toEntity() => DashboardStats(
    totalMedications: totalMedications, reportsCount: reportsCount, lastVitalCheck: lastVitalCheck,
  );

  Map<String, dynamic> toJson() => {
    'totalMedications': totalMedications,
    'reportsCount': reportsCount,
    if (lastVitalCheck != null) 'lastVitalCheck': lastVitalCheck!.toIso8601String(),
  };
}

class ActivityItemDto {
  final String id;
  final String title;
  final DateTime timestamp;
  final ActivityType type;

  const ActivityItemDto({
    required this.id, required this.title, required this.timestamp, required this.type,
  });

  factory ActivityItemDto.fromEntity(ActivityItem e) => ActivityItemDto(
    id: e.id, title: e.title, timestamp: e.timestamp, type: e.type,
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'title': title,
    'timestamp': timestamp.toIso8601String(),
    'type': type.name,
  };
}
