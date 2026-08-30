import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/core/audit/phi_audit_event.dart';

void main() {
  group('PhiAuditEvent', () {
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

    test('empty constructor is supported for Isar codegen', () {
      final event = PhiAuditEvent()
        ..userId = 'user2'
        ..action = 'write'
        ..resourceType = 'medication'
        ..resourceId = 'med_789';

      expect(event.userId, 'user2');
      expect(event.action, 'write');
    });
  });

  group('Action enum-like values', () {
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