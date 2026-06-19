import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/doctor_verification/domain/entities/reputation_badge.dart';

void main() {
  group('ReputationBadge entity', () {
    test('should support instantiation', () {
      final tDate = DateTime(2023, 1, 1);
      final badge = ReputationBadge(
        id: 'b1',
        doctorId: 'doc1',
        level: BadgeLevel.gold,
        criteria: 'Excellence',
        earnedDate: tDate,
      );

      expect(badge.id, 'b1');
      expect(badge.doctorId, 'doc1');
      expect(badge.level, BadgeLevel.gold);
      expect(badge.criteria, 'Excellence');
      expect(badge.earnedDate, tDate);
    });
  });
}
