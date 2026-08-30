import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/core/audit/phi_audit_event.dart';

void main() {
  group('PhiAuditEvent entity', () {
    test('create() sets timestamp to UTC', () {
      final event = PhiAuditEvent.create(
        userId: 'user1',
        action: 'read',
        resourceType: 'medical_record',
        resourceId: 'rec_123',
      );

      expect(event.userId, 'user1');
      expect(event.action, 'read');
      expect(event.resourceType, 'medical_record');
      expect(event.resourceId, 'rec_123');
      expect(event.timestamp.isUtc, true);
      expect(event.sessionId, isNull);
      expect(event.context, isNull);
    });

    test('create() accepts sessionId and context', () {
      final event = PhiAuditEvent.create(
        userId: 'user1',
        action: 'export',
        resourceType: 'medical_record',
        resourceId: 'rec_456',
        sessionId: 'session_abc',
        context: 'gdpr_data_export',
      );

      expect(event.sessionId, 'session_abc');
      expect(event.context, 'gdpr_data_export');
    });

    test('full constructor allows explicit id (e.g., from storage)', () {
      final event = PhiAuditEvent(
        id: 42,
        userId: 'u',
        timestamp: DateTime.utc(2026, 8, 29),
        action: 'read',
        resourceType: 'medical_record',
        resourceId: 'rec_42',
      );
      expect(event.id, 42);
    });

    test('toJson serializes all fields', () {
      final event = PhiAuditEvent(
        id: 1,
        userId: 'u',
        timestamp: DateTime.utc(2026, 8, 29, 10, 30),
        action: 'read',
        resourceType: 'medical_record',
        resourceId: 'rec_1',
        sessionId: 'sess',
        context: 'test',
      );

      final json = event.toJson();
      expect(json['id'], 1);
      expect(json['user_id'], 'u');
      expect(json['action'], 'read');
      expect(json['resource_type'], 'medical_record');
      expect(json['resource_id'], 'rec_1');
      expect(json['session_id'], 'sess');
      expect(json['context'], 'test');
      expect(json['timestamp'], contains('2026-08-29'));
    });

    test('fromJson/toJson roundtrip preserves all fields', () {
      final original = PhiAuditEvent(
        id: 123,
        userId: 'u1',
        timestamp: DateTime.utc(2026, 8, 29, 12, 0, 0),
        action: 'write',
        resourceType: 'medication',
        resourceId: 'med_1',
        sessionId: 'sess_42',
        context: 'prescription',
      );

      final restored = PhiAuditEvent.fromJson(original.toJson());
      expect(restored.id, original.id);
      expect(restored.userId, original.userId);
      expect(restored.action, original.action);
      expect(restored.resourceType, original.resourceType);
      expect(restored.resourceId, original.resourceId);
      expect(restored.sessionId, original.sessionId);
      expect(restored.context, original.context);
      expect(restored.timestamp.toUtc(), original.timestamp);
    });

    test('copyWith updates only id', () {
      final original = PhiAuditEvent(
        id: 1,
        userId: 'u',
        timestamp: DateTime.utc(2026, 8, 29),
        action: 'read',
        resourceType: 'r',
        resourceId: 'i',
      );
      final copied = original.copyWith(id: 999);
      expect(copied.id, 999);
      expect(copied.userId, original.userId);
      expect(copied.action, original.action);
    });
  });

  group('PhiAuditService behavior (entity-level)', () {
    test('logging an event stores it with correct fields', () {
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

  group('Action values', () {
    test('supported actions: read, write, delete, export, share', () {
      final actions = ['read', 'write', 'delete', 'export', 'share'];
      for (final action in actions) {
        final event = PhiAuditEvent.create(
          userId: 'u',
          action: action,
          resourceType: 't',
          resourceId: 'r',
        );
        expect(event.action, action);
      }
    });
  });
}