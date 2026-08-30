/// Ley 1581 Art. 17 — ARCO rights request
///
/// Records a user's request to exercise one of their 4 ARCO rights
/// (Acceso, Rectificación, Cancelación, Oposición). Each request
/// generates a ticket that can be tracked to completion.
class ArcoRequest {
  final String requestId;
  final String userId;
  final ArcoRightType type;
  final ArcoRequestStatus status;
  final DateTime submittedAt;
  final DateTime? processedAt;
  final String? notes;
  final String? details;

  ArcoRequest({
    required this.requestId,
    required this.userId,
    required this.type,
    required this.status,
    required this.submittedAt,
    this.processedAt,
    this.notes,
    this.details,
  });

  ArcoRequest copyWith({
    ArcoRequestStatus? status,
    DateTime? processedAt,
    String? notes,
  }) {
    return ArcoRequest(
      requestId: requestId,
      userId: userId,
      type: type,
      status: status ?? this.status,
      submittedAt: submittedAt,
      processedAt: processedAt ?? this.processedAt,
      notes: notes ?? this.notes,
      details: details,
    );
  }

  Map<String, dynamic> toJson() => {
        'request_id': requestId,
        'user_id': userId,
        'type': type.name,
        'status': status.name,
        'submitted_at': submittedAt.toUtc().toIso8601String(),
        'processed_at': processedAt?.toUtc().toIso8601String(),
        'notes': notes,
        'details': details,
      };
}

enum ArcoRightType {
  /// Acceso (Access) — export all user data
  access,

  /// Rectificación (Rectification) — correct inaccurate data
  rectification,

  /// Cancelación (Cancellation/Erasure) — delete data
  cancellation,

  /// Oposición (Opposition) — object to specific processing
  opposition,
}

enum ArcoRequestStatus {
  pending,
  processing,
  processed,
  denied,
}

/// Display labels for ARCO rights in Spanish.
class ArcoRightLabels {
  static const Map<ArcoRightType, String> titles = {
    ArcoRightType.access: 'Acceso',
    ArcoRightType.rectification: 'Rectificación',
    ArcoRightType.cancellation: 'Cancelación',
    ArcoRightType.opposition: 'Oposición',
  };

  static const Map<ArcoRightType, String> descriptions = {
    ArcoRightType.access:
        'Exportar todos mis datos personales en formato portable (JSON/ZIP).',
    ArcoRightType.rectification:
        'Solicitar corrección de datos inexactos en mi perfil o historial.',
    ArcoRightType.cancellation:
        'Eliminar todos o parte de mis datos personales (derecho al olvido).',
    ArcoRightType.opposition:
        'Objetar el procesamiento de mis datos para fines específicos.',
  };
}