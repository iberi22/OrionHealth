import '../../domain/entities/dashboard_stats.dart';
import '../../domain/entities/activity_item.dart';

class DashboardStatsDto {
  final int totalMedications;
  final int reportsCount;
  final DateTime? lastVitalCheck;

  const DashboardStatsDto({
    required this.totalMedications,
    required this.reportsCount,
    this.lastVitalCheck,
  });

  factory DashboardStatsDto.fromJson(Map<String, dynamic> json) => DashboardStatsDto(
        totalMedications: json['totalMedications'] as int,
        reportsCount: json['reportsCount'] as int,
        lastVitalCheck: json['lastVitalCheck'] != null
            ? DateTime.parse(json['lastVitalCheck'] as String)
            : null,
      );

  DashboardStats toEntity() => DashboardStats(
        totalMedications: totalMedications,
        reportsCount: reportsCount,
        lastVitalCheck: lastVitalCheck,
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
    required this.id,
    required this.title,
    required this.timestamp,
    required this.type,
  });

  factory ActivityItemDto.fromJson(Map<String, dynamic> json) => ActivityItemDto(
        id: json['id'] as String,
        title: json['title'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        type: ActivityType.values.firstWhere((e) => e.name == json['type']),
      );

  factory ActivityItemDto.fromEntity(ActivityItem e) => ActivityItemDto(
        id: e.id,
        title: e.title,
        timestamp: e.timestamp,
        type: e.type,
      );

  ActivityItem toEntity() => ActivityItem(
        id: id,
        title: title,
        timestamp: timestamp,
        type: type,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'timestamp': timestamp.toIso8601String(),
        'type': type.name,
      };
}
