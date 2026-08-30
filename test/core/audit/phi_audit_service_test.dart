import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/core/audit/phi_audit_service.dart';
import 'package:orionhealth_health/core/services/secure_storage_service.dart';

class _InMemoryStorage implements SecureStorageService {
  final Map<String, String> _data = {};

  @override
  Future<String?> read(String key) async => _data[key];

  @override
  Future<void> write(String key, String value) async {
    _data[key] = value;
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('PhiAuditService', () {
    late _InMemoryStorage storage;
    late PhiAuditService service;

    setUp(() {
      storage = _InMemoryStorage();
      service = PhiAuditService(storage);
    });

    test('logAccess returns event with id and UTC timestamp', () async {
      final event = await service.logAccess(
        userId: 'u1',
        action: 'read',
        resourceType: 'medical_record',
        resourceId: 'rec_1',
      );

      expect(event.id, 1);
      expect(event.timestamp.isUtc, true);
    });

    test('logAccess persists event for retrieval', () async {
      await service.logAccess(
        userId: 'u1',
        action: 'read',
        resourceType: 'medical_record',
        resourceId: 'rec_1',
      );

      final events = await service.getEventsForUser('u1');
      expect(events.length, 1);
      expect(events.first.userId, 'u1');
      expect(events.first.action, 'read');
    });

    test('multiple events get unique incrementing ids', () async {
      final e1 = await service.logAccess(
        userId: 'u',
        action: 'read',
        resourceType: 'r',
        resourceId: 'i1',
      );
      final e2 = await service.logAccess(
        userId: 'u',
        action: 'write',
        resourceType: 'r',
        resourceId: 'i2',
      );
      final e3 = await service.logAccess(
        userId: 'u',
        action: 'delete',
        resourceType: 'r',
        resourceId: 'i3',
      );

      expect(e1.id, 1);
      expect(e2.id, 2);
      expect(e3.id, 3);
    });

    test('getEventsForUser filters by userId', () async {
      await service.logAccess(
        userId: 'u1',
        action: 'read',
        resourceType: 'r',
        resourceId: 'i1',
      );
      await service.logAccess(
        userId: 'u2',
        action: 'read',
        resourceType: 'r',
        resourceId: 'i2',
      );
      await service.logAccess(
        userId: 'u1',
        action: 'write',
        resourceType: 'r',
        resourceId: 'i3',
      );

      final u1 = await service.getEventsForUser('u1');
      final u2 = await service.getEventsForUser('u2');

      expect(u1.length, 2);
      expect(u2.length, 1);
      expect(u1.every((e) => e.userId == 'u1'), true);
      expect(u2.first.userId, 'u2');
    });

    test('getEventsForUser respects limit', () async {
      for (int i = 0; i < 5; i++) {
        await service.logAccess(
          userId: 'u1',
          action: 'read',
          resourceType: 'r',
          resourceId: 'rec_$i',
        );
      }

      final events = await service.getEventsForUser('u1', limit: 3);
      expect(events.length, 3);
    });

    test('getEventsForResource returns forensic trail', () async {
      await service.logAccess(
        userId: 'u1',
        action: 'read',
        resourceType: 'medical_record',
        resourceId: 'rec_special',
      );
      await service.logAccess(
        userId: 'u2',
        action: 'export',
        resourceType: 'medical_record',
        resourceId: 'rec_special',
      );
      await service.logAccess(
        userId: 'u3',
        action: 'read',
        resourceType: 'medical_record',
        resourceId: 'rec_other',
      );

      final trail = await service.getEventsForResource(
        resourceType: 'medical_record',
        resourceId: 'rec_special',
      );

      expect(trail.length, 2);
      expect(trail.every((e) => e.resourceId == 'rec_special'), true);
    });

    test('getEventsInRange filters by date range', () async {
      await service.logAccess(
        userId: 'u',
        action: 'read',
        resourceType: 'r',
        resourceId: 'now',
      );

      final now = DateTime.now();
      final events = await service.getEventsInRange(
        userId: 'u',
        from: now.subtract(const Duration(hours: 1)),
        to: now.add(const Duration(hours: 1)),
      );

      expect(events.length, greaterThanOrEqualTo(1));
    });

    test('events are returned most-recent-first', () async {
      await service.logAccess(
        userId: 'u',
        action: 'read',
        resourceType: 'r',
        resourceId: 'first',
      );
      // Small delay to ensure timestamp difference
      await Future.delayed(const Duration(milliseconds: 10));
      await service.logAccess(
        userId: 'u',
        action: 'write',
        resourceType: 'r',
        resourceId: 'second',
      );

      final events = await service.getEventsForUser('u');
      expect(events[0].resourceId, 'second');
      expect(events[1].resourceId, 'first');
    });

    test('logAccess with optional fields persists correctly', () async {
      await service.logAccess(
        userId: 'u',
        action: 'export',
        resourceType: 'medical_record',
        resourceId: 'r',
        sessionId: 'sess_42',
        context: 'gdpr_export',
      );

      final events = await service.getEventsForUser('u');
      expect(events.first.sessionId, 'sess_42');
      expect(events.first.context, 'gdpr_export');
    });
  });
}