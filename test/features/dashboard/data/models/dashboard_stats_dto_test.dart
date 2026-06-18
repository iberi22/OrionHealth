import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/dashboard/data/models/dashboard_stats_dto.dart';
import 'package:orionhealth_health/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:orionhealth_health/features/dashboard/domain/entities/activity_item.dart';

void main() {
  group('DashboardStatsDto', () {
    final now = DateTime.now();

    test('toEntity creates DashboardStats', () {
      final dto = DashboardStatsDto(
        totalMedications: 5,
        reportsCount: 3,
        lastVitalCheck: now,
      );
      final entity = dto.toEntity();
      expect(
        entity,
        equals(
          DashboardStats(
            totalMedications: 5,
            reportsCount: 3,
            lastVitalCheck: now,
          ),
        ),
      );
    });

    test('toEntity handles null lastVitalCheck', () {
      final dto = DashboardStatsDto(totalMedications: 0, reportsCount: 0);
      final entity = dto.toEntity();
      expect(entity.lastVitalCheck, isNull);
    });

    test('toJson includes lastVitalCheck when not null', () {
      final dto = DashboardStatsDto(
        totalMedications: 5,
        reportsCount: 3,
        lastVitalCheck: now,
      );
      final json = dto.toJson();
      expect(json['totalMedications'], 5);
      expect(json['reportsCount'], 3);
      expect(json['lastVitalCheck'], now.toIso8601String());
    });

    test('toJson omits lastVitalCheck when null', () {
      final dto = DashboardStatsDto(totalMedications: 0, reportsCount: 0);
      final json = dto.toJson();
      expect(json.containsKey('lastVitalCheck'), isFalse);
    });
  });

  group('ActivityItemDto', () {
    final now = DateTime.now();
    final item = ActivityItem(
      id: '1',
      title: 'Checkup',
      timestamp: now,
      type: ActivityType.appointment,
    );

    test('fromEntity copies fields', () {
      final dto = ActivityItemDto.fromEntity(item);
      expect(dto.id, '1');
      expect(dto.title, 'Checkup');
      expect(dto.timestamp, now);
      expect(dto.type, ActivityType.appointment);
    });

    test('toJson serializes correctly', () {
      final dto = ActivityItemDto.fromEntity(item);
      final json = dto.toJson();
      expect(json['id'], '1');
      expect(json['title'], 'Checkup');
      expect(json['timestamp'], now.toIso8601String());
      expect(json['type'], 'appointment');
    });

    test('fromEntity roundtrip with medicationTaken type', () {
      final medItem = ActivityItem(
        id: '2',
        title: 'Take Losartan',
        timestamp: now,
        type: ActivityType.medicationTaken,
      );
      final dto = ActivityItemDto.fromEntity(medItem);
      expect(dto.type, ActivityType.medicationTaken);
      expect(dto.toJson()['type'], 'medicationTaken');
    });

    test('fromEntity roundtrip with other type', () {
      final otherItem = ActivityItem(
        id: '3',
        title: 'Other activity',
        timestamp: now,
        type: ActivityType.other,
      );
      final dto = ActivityItemDto.fromEntity(otherItem);
      expect(dto.type, ActivityType.other);
      expect(dto.toJson()['type'], 'other');
    });
  });
}
