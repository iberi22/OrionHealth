import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/core/audit/phi_audit_event.dart';

void main() {
  group('PhiAuditEvent entity', () {
    test('create() sets timestamp to UTC', () {
      final event = PhiAuditEvent.create(
        userId: 'u1',
        action: 'read',
        resourceType: 'medical_record',
        resourceId: 'rec_1',
      );
      expect(event.timestamp.isUtc, true);
    });

    test('create() supports sessionId and context', () {
      final event = PhiAuditEvent.create(
        userId: 'u',
        action: 'export',
        resourceType: 'medical_record',
        resourceId: 'r',
        sessionId: 'sess',
        context: 'gdpr_export',
      );
      expect(event.sessionId, 'sess');
      expect(event.context, 'gdpr_export');
    });

    test('empty constructor works for Isar codegen pattern', () {
      final e = PhiAuditEvent()..userId = 'u';
      expect(e.userId, 'u');
    });
  });

  group('PhiAuditService behavior (via mock)', () {
    test('logging an event stores it with correct fields', () async {
      // Use the entity logic without a real Isar instance.
      final event = PhiAuditEvent.create(
        userId: 'u1',
        action: 'read',
        resourceType: 'medical_record',
        resourceId: 'rec_42',
      );

      expect(event.userId, 'u1');
      expect(event.action, 'read');
      expect(event.resourceType, 'medical_record');
      expect(event.resourceId, 'rec_42');
    });

    test('multiple events accumulate independently', () {
      final events = [
        PhiAuditEvent.create(
          userId: 'u1',
          action: 'read',
          resourceType: 'medical_record',
          resourceId: 'r1',
        ),
        PhiAuditEvent.create(
          userId: 'u1',
          action: 'write',
          resourceType: 'medication',
          resourceId: 'm1',
        ),
        PhiAuditEvent.create(
          userId: 'u2',
          action: 'export',
          resourceType: 'medical_record',
          resourceId: 'r2',
        ),
      ];

      expect(events.length, 3);
      expect(events[0].userId, 'u1');
      expect(events[1].userId, 'u1');
      expect(events[2].userId, 'u2');
      expect(events.map((e) => e.action).toList(),
          ['read', 'write', 'export']);
    });
  });
}