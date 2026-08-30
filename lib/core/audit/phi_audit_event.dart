import 'package:isar/isar.dart';

part 'phi_audit_event.g.dart';

/// HIPAA 45 CFR § 164.312(b) — Audit Controls
///
/// Logs every access to PHI (Protected Health Information) for compliance.
/// Events are append-only and immutable (cannot be edited or deleted by
/// application code).
@collection
class PhiAuditEvent {
  Id id = Isar.autoIncrement;

  /// User who performed the access
  @Index()
  late String userId;

  /// UTC timestamp of the access event
  @Index()
  late DateTime timestamp;

  /// Action performed: read, write, delete, export, share
  @Index()
  late String action;

  /// Type of resource accessed: medical_record, medication, vital, etc.
  @Index()
  late String resourceType;

  /// Specific resource ID (never log PHI content — only IDs)
  late String resourceId;

  /// Optional session ID for correlation
  String? sessionId;

  /// Optional context (e.g., "export_zip", "share_p2p")
  String? context;

  PhiAuditEvent();

  PhiAuditEvent.create({
    required this.userId,
    required this.action,
    required this.resourceType,
    required this.resourceId,
    this.sessionId,
    this.context,
  }) : timestamp = DateTime.now().toUtc();
}