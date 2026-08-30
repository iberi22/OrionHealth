import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/user_profile/domain/entities/arco_request.dart';

void main() {
  group('ArcoRequest', () {
    test('copyWith updates only specified fields', () {
      final original = ArcoRequest(
        requestId: 'req_001',
        userId: 'u1',
        type: ArcoRightType.access,
        status: ArcoRequestStatus.pending,
        submittedAt: DateTime.utc(2026, 8, 29),
      );

      final updated = original.copyWith(
        status: ArcoRequestStatus.processed,
        notes: 'Export delivered',
      );

      expect(updated.requestId, 'req_001');
      expect(updated.userId, 'u1');
      expect(updated.type, ArcoRightType.access);
      expect(updated.status, ArcoRequestStatus.processed);
      expect(updated.notes, 'Export delivered');
      expect(updated.submittedAt, original.submittedAt);
    });

    test('toJson serializes all fields', () {
      final r = ArcoRequest(
        requestId: 'req_002',
        userId: 'u2',
        type: ArcoRightType.cancellation,
        status: ArcoRequestStatus.processing,
        submittedAt: DateTime.utc(2026, 8, 29),
      );

      final json = r.toJson();
      expect(json['request_id'], 'req_002');
      expect(json['user_id'], 'u2');
      expect(json['type'], 'cancellation');
      expect(json['status'], 'processing');
      expect(json['submitted_at'], '2026-08-29T00:00:00.000Z');
    });
  });

  group('ArcoRightType enum', () {
    test('has 4 values matching Ley 1581 ARCO rights', () {
      expect(ArcoRightType.values.length, 4);
      expect(ArcoRightType.values, containsAll([
        ArcoRightType.access,
        ArcoRightType.rectification,
        ArcoRightType.cancellation,
        ArcoRightType.opposition,
      ]));
    });
  });

  group('ArcoRightLabels', () {
    test('all 4 rights have Spanish titles and descriptions', () {
      for (final type in ArcoRightType.values) {
        expect(ArcoRightLabels.titles[type], isNotNull);
        expect(ArcoRightLabels.titles[type], isNotEmpty);
        expect(ArcoRightLabels.descriptions[type], isNotNull);
        expect(ArcoRightLabels.descriptions[type], isNotEmpty);
      }
    });
  });

  group('ArcoRequestStatus enum', () {
    test('has 4 states: pending, processing, processed, denied', () {
      expect(ArcoRequestStatus.values.length, 4);
      expect(ArcoRequestStatus.values, containsAll([
        ArcoRequestStatus.pending,
        ArcoRequestStatus.processing,
        ArcoRequestStatus.processed,
        ArcoRequestStatus.denied,
      ]));
    });
  });
}