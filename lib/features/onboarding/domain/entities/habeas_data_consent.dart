/// Ley 1581 de 2012 — Habeas Data consent
///
/// Records the user's explicit consent for personal data processing
/// under Colombian data protection law. Required before any PHI collection.
class HabeasDataConsent {
  final String userId;
  final DateTime acceptedAt;
  final String documentVersion;
  final bool arcoRightsAccepted;
  final bool processingPurposeAccepted;
  final bool dataSharingAccepted;

  const HabeasDataConsent({
    required this.userId,
    required this.acceptedAt,
    required this.documentVersion,
    required this.arcoRightsAccepted,
    required this.processingPurposeAccepted,
    required this.dataSharingAccepted,
  });

  bool get isFullyAccepted =>
      arcoRightsAccepted &&
      processingPurposeAccepted &&
      dataSharingAccepted;

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'accepted_at': acceptedAt.toUtc().toIso8601String(),
        'document_version': documentVersion,
        'arco_rights_accepted': arcoRightsAccepted,
        'processing_purpose_accepted': processingPurposeAccepted,
        'data_sharing_accepted': dataSharingAccepted,
      };
}

/// Static text constants for the Habeas Data document.
class HabeasDataDocument {
  static const String currentVersion = 'v1.0-2026-08-29';

  static const String title = 'Ley 1581 de 2012 — Habeas Data';

  static const String intro =
      'En cumplimiento de la Ley 1581 de 2012 (Colombia) sobre protección '
      'de datos personales, OrionHealth requiere su consentimiento expreso '
      'e informado antes de recolectar cualquier dato personal.';

  static const String dataCollected =
      'Datos personales recolectados:\n'
      '• Nombre, edad, sexo biológico\n'
      '• Historial médico, medicamentos, alergias\n'
      '• Signos vitales, citas, reportes\n'
      '• Resultados de evaluaciones clínicas\n'
      '• Configuración de la aplicación\n'
      '• Registro de auditoría de accesos a datos (HIPAA)';

  static const String purpose =
      'Finalidad del tratamiento:\n'
      '• Análisis personalizado de síntomas\n'
      '• Detección de interacciones farmacológicas\n'
      '• Interpretación de resultados de laboratorio\n'
      '• Análisis de tendencias de salud\n'
      '• Generación de alertas médicas\n'
      '• Identidad auto-soberana (credenciales verificables)';

  static const String arcoRights =
      'Derechos ARCO (Art. 17):\n'
      '• Acceso: exportar todos sus datos\n'
      '• Rectificación: corregir datos inexactos\n'
      '• Cancelación: eliminar datos (total o parcialmente)\n'
      '• Oposición: objetar procesamiento para fines específicos';

  static const String dataSharing =
      'Cesión de datos:\n'
      'OrionHealth NO comparte sus datos con terceros bajo ninguna '
      'circunstancia. No hay marketing, analytics, ni respaldos en la nube. '
      'Sus datos permanecen exclusivamente en su dispositivo.';

  static const String acceptance =
      'Al aceptar este documento, usted certifica que:\n'
      '1. Ha leído y comprendido la información anterior\n'
      '2. Otorga su consentimiento expreso para el tratamiento\n'
      '3. Conoce sus derechos ARCO y cómo ejercerlos\n'
      '4. Puede retirar este consentimiento en cualquier momento';
}