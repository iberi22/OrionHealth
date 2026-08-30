import 'package:isar/isar.dart';
import 'package:injectable/injectable.dart';

import 'phi_audit_event.dart';

/// HIPAA 45 CFR § 164.312(b) — Audit Controls
///
/// Records PHI access events. Append-only. The Isar collection is not
/// deleted or modified by application code (except by secure admin tools).
@lazySingleton
class PhiAuditService {
  final Isar _isar;

  PhiAuditService(this._isar);

  /// Records a PHI access event. Does NOT log PHI content, only IDs.
  Future<void> logAccess({
    required String userId,
    required String action,
    required String resourceType,
    required String resourceId,
    String? sessionId,
    String? context,
  }) async {
    await _isar.writeTxn(() async {
      await _isar.phiAuditEvents.put(
        PhiAuditEvent.create(
          userId: userId,
          action: action,
          resourceType: resourceType,
          resourceId: resourceId,
          sessionId: sessionId,
          context: context,
        ),
      );
    });
  }

  /// Returns all audit events for a user, most recent first.
  Future<List<PhiAuditEvent>> getEventsForUser(String userId,
      {int? limit}) async {
    final query = _isar.phiAuditEvents
        .filter()
        .userIdEqualTo(userId)
        .sortByTimestampDesc();
    if (limit != null) {
      return await query.limit(limit).findAll();
    }
    return await query.findAll();
  }

  /// Returns events for a specific resource (forensic trail).
  Future<List<PhiAuditEvent>> getEventsForResource({
    required String resourceType,
    required String resourceId,
  }) async {
    return await _isar.phiAuditEvents
        .filter()
        .resourceTypeEqualTo(resourceType)
        .resourceIdEqualTo(resourceId)
        .sortByTimestampDesc()
        .findAll();
  }

  /// Returns events in a date range.
  Future<List<PhiAuditEvent>> getEventsInRange({
    required String userId,
    required DateTime from,
    required DateTime to,
  }) async {
    return await _isar.phiAuditEvents
        .filter()
        .userIdEqualTo(userId)
        .timestampBetween(from, to)
        .sortByTimestampDesc()
        .findAll();
  }
}