import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/dashboard/domain/entities/activity_item.dart';

void main() {
  group('ActivityItem', () {
    final now = DateTime.now();

    test('supports value equality', () {
      expect(
        ActivityItem(
          id: '1',
          title: 'Medication taken',
          timestamp: now,
          type: ActivityType.medicationTaken,
        ),
        ActivityItem(
          id: '1',
          title: 'Medication taken',
          timestamp: now,
          type: ActivityType.medicationTaken,
        ),
      );
    });

    test('props are correct', () {
      final activity = ActivityItem(
        id: '1',
        title: 'Vitals checked',
        timestamp: now,
        type: ActivityType.vitalCheck,
      );
      expect(activity.props, ['1', 'Vitals checked', now, ActivityType.vitalCheck]);
    });

    test('supports different values', () {
      final act1 = ActivityItem(
        id: '1',
        title: 'Appointment',
        timestamp: now,
        type: ActivityType.appointment,
      );
      final act2 = ActivityItem(
        id: '2',
        title: 'Report',
        timestamp: now,
        type: ActivityType.reportGenerated,
      );
      expect(act1, isNot(equals(act2)));
    });

    test('has correct ActivityType enum values', () {
      expect(ActivityType.values, hasLength(5));
      expect(ActivityType.values, containsAll([
        ActivityType.vitalCheck,
        ActivityType.medicationTaken,
        ActivityType.reportGenerated,
        ActivityType.appointment,
        ActivityType.other,
      ]));
    });
  });
}
