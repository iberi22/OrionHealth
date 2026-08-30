import 'dart:async';
import 'dart:convert';

import 'package:injectable/injectable.dart';

import '../../../../core/services/secure_storage_service.dart';
import 'phi_audit_event.dart';

/// HIPAA 45 CFR § 164.312(b) — Audit Controls
///
/// Persists PHI access events to a JSON-encoded SecureStorage key.
/// Append-only by convention (no delete/update methods exposed).
///
/// In a production environment, this would use a dedicated audit log
/// service (e.g., SIEM). For privacy-first local app, SecureStorage with
/// explicit encryption is appropriate.
@lazySingleton
class PhiAuditService {
  final SecureStorageService _secureStorage;

  PhiAuditService(this._secureStorage);

  static const String _storageKey = 'phi_audit_log';
  static const int _maxEventsInMemory = 10000;

  /// Records a PHI access event.
  Future<PhiAuditEvent> logAccess({
    required String userId,
    required String action,
    required String resourceType,
    required String resourceId,
    String? sessionId,
    String? context,
  }) async {
    final existing = await _loadEvents();
    final nextId = existing.isEmpty
        ? 1
        : existing.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1;

    final event = PhiAuditEvent(
      id: nextId,
      userId: userId,
      timestamp: DateTime.now().toUtc(),
      action: action,
      resourceType: resourceType,
      resourceId: resourceId,
      sessionId: sessionId,
      context: context,
    );

    final updated = [...existing, event];
    // Cap memory: drop oldest if over limit
    if (updated.length > _maxEventsInMemory) {
      updated.removeRange(0, updated.length - _maxEventsInMemory);
    }

    await _saveEvents(updated);
    return event;
  }

  /// Returns all audit events for a user, most recent first.
  Future<List<PhiAuditEvent>> getEventsForUser(String userId,
      {int? limit}) async {
    final all = await _loadEvents();
    final filtered = all.where((e) => e.userId == userId).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    if (limit != null && filtered.length > limit) {
      return filtered.sublist(0, limit);
    }
    return filtered;
  }

  /// Returns events for a specific resource (forensic trail).
  Future<List<PhiAuditEvent>> getEventsForResource({
    required String resourceType,
    required String resourceId,
  }) async {
    final all = await _loadEvents();
    return all
        .where((e) =>
            e.resourceType == resourceType && e.resourceId == resourceId)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  /// Returns events in a date range.
  Future<List<PhiAuditEvent>> getEventsInRange({
    required String userId,
    required DateTime from,
    required DateTime to,
  }) async {
    final all = await _loadEvents();
    return all
        .where((e) =>
            e.userId == userId &&
            !e.timestamp.isBefore(from) &&
            !e.timestamp.isAfter(to))
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  Future<List<PhiAuditEvent>> _loadEvents() async {
    final raw = await _secureStorage.read(_storageKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((j) => PhiAuditEvent.fromJson(j as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> _saveEvents(List<PhiAuditEvent> events) async {
    final json = jsonEncode(events.map((e) => e.toJson()).toList());
    await _secureStorage.write(_storageKey, json);
  }
}