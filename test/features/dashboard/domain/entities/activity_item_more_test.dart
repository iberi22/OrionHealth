import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/dashboard/domain/entities/activity_item.dart';

void main() {
  group('ActivityItem More Tests', () {
    test('supports different types', () {
      final item1 = ActivityItem(
        id: '1',
        title: 'Title',
        timestamp: DateTime(2024),
        type: ActivityType.appointment,
      );
      final item2 = ActivityItem(
        id: '2',
        title: 'Title',
        timestamp: DateTime(2024),
        type: ActivityType.vitalCheck,
      );
      expect(item1.type, ActivityType.appointment);
      expect(item2.type, ActivityType.vitalCheck);
    });

    test('equality works with all props', () {
      final date = DateTime(2024);
      final item1 = ActivityItem(
        id: '1',
        title: 'T',
        timestamp: date,
        type: ActivityType.appointment,
      );
      final item2 = ActivityItem(
        id: '1',
        title: 'T',
        timestamp: date,
        type: ActivityType.appointment,
      );
      expect(item1, equals(item2));
    });
  });
}
