/// HIPAA 45 CFR § 164.312(b) — Audit Controls
///
/// Plain Dart entity (no Isar codegen) to keep build_runner out of CI.
/// Persisted via secure storage as JSON-encoded audit log.
///
/// Logs every access to PHI (Protected Health Information) for compliance.
/// Events are append-only and immutable (cannot be edited by application code).
class PhiAuditEvent {
  /// Auto-incremented event ID
  final int id;

  /// User who performed the access
  final String userId;

  /// UTC timestamp of the access event
  final DateTime timestamp;

  /// Action performed: read, write, delete, export, share
  final String action;

  /// Type of resource accessed: medical_record, medication, vital, etc.
  final String resourceType;

  /// Specific resource ID (never log PHI content — only IDs)
  final String resourceId;

  /// Optional session ID for correlation
  final String? sessionId;

  /// Optional context (e.g., "export_zip", "share_p2p")
  final String? context;

  const PhiAuditEvent({
    required this.id,
    required this.userId,
    required this.timestamp,
    required this.action,
    required this.resourceType,
    required this.resourceId,
    this.sessionId,
    this.context,
  });

  /// Factory: creates a new event with auto-incremented ID.
  /// Caller is responsible for assigning IDs (typically by querying existing
  /// events and incrementing).
  factory PhiAuditEvent.create({
    required String userId,
    required String action,
    required String resourceType,
    required String resourceId,
    String? sessionId,
    String? context,
  }) {
    return PhiAuditEvent(
      id: -1, // Caller must assign
      userId: userId,
      timestamp: DateTime.now().toUtc(),
      action: action,
      resourceType: resourceType,
      resourceId: resourceId,
      sessionId: sessionId,
      context: context,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'timestamp': timestamp.toUtc().toIso8601String(),
        'action': action,
        'resource_type': resourceType,
        'resource_id': resourceId,
        'session_id': sessionId,
        'context': context,
      };

  factory PhiAuditEvent.fromJson(Map<String, dynamic> json) {
    return PhiAuditEvent(
      id: json['id'] as int,
      userId: json['user_id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      action: json['action'] as String,
      resourceType: json['resource_type'] as String,
      resourceId: json['resource_id'] as String,
      sessionId: json['session_id'] as String?,
      context: json['context'] as String?,
    );
  }

  PhiAuditEvent copyWith({int? id}) {
    return PhiAuditEvent(
      id: id ?? this.id,
      userId: userId,
      timestamp: timestamp,
      action: action,
      resourceType: resourceType,
      resourceId: resourceId,
      sessionId: sessionId,
      context: context,
    );
  }
}