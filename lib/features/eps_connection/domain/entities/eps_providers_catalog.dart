// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

/// Catálogo de Entidades Promotoras de Salud (EPS) de Colombia.
///
/// Fuente oficial: Registro Especial de Prestadores de Servicios de Salud (REPS)
/// https://prestadores.minsalud.gov.co/habilitacion/
///
/// La interoperabilidad en Colombia se realiza a través de la plataforma
/// IHCE (Interoperabilidad de Historia Clínica Electrónica) de Minsalud,
/// que utiliza HL7 FHIR R4 como estándar desde la Resolución 1888 de 2025,
/// con implementación obligatoria desde el 15 de abril de 2026.
///
/// Para conexión real, OrionHealth se conecta a la API IHCE de Minsalud
/// como intermediario central, no directamente a cada EPS.

import 'eps_provider.dart';

/// Catálogo oficial de EPS activas en Colombia (2026).
class EpsProvidersCatalog {
  EpsProvidersCatalog._();

  /// Lista completa de EPS activas en Colombia según REPS.
  static List<EPSProvider> get activeProviders => _buildProviders();

  static List<EPSProvider> _buildProviders() {
    return [
      _eps(
        id: 'EPS025',
        name: 'E.P.S. SURA',
        regime: 'Contributivo',
      ),
      _eps(
        id: 'EPS008',
        name: 'Compensar E.P.S.',
        regime: 'Contributivo',
      ),
      _eps(
        id: 'EPS005',
        name: 'Sanitas E.P.S.',
        regime: 'Contributivo',
      ),
      _eps(
        id: 'EPS037',
        name: 'Nueva EPS',
        regime: 'Contributivo',
      ),
      _eps(
        id: 'EPS002',
        name: 'Salud Total E.P.S.',
        regime: 'Contributivo',
      ),
      _eps(
        id: 'EPS017',
        name: 'Famisanar E.P.S.',
        regime: 'Contributivo',
      ),
      _eps(
        id: 'EPS044',
        name: 'Alianza Medellín Antioquia E.P.S.',
        regime: 'Contributivo',
      ),
      _eps(
        id: 'EPS045',
        name: 'Savia Salud E.P.S.',
        regime: 'Contributivo',
      ),
      _eps(
        id: 'EPS042',
        name: 'Salud Bolívar E.P.S.',
        regime: 'Contributivo',
      ),
      _eps(
        id: 'EPS043',
        name: 'Cruz Blanca E.P.S.',
        regime: 'Contributivo',
      ),
      _eps(
        id: 'EPS033',
        name: 'Mutual SER E.S.S.',
        regime: 'Subsidiado',
      ),
      _eps(
        id: 'EPS012',
        name: 'Comfamiliar Huila E.P.S.',
        regime: 'Subsidiado',
      ),
      _eps(
        id: 'EPS010',
        name: 'Comfenalco Valle E.P.S.',
        regime: 'Subsidiado',
      ),
      _eps(
        id: 'EPSI005',
        name: 'Mallamas E.P.S.I.',
        regime: 'Especial',
      ),
      _eps(
        id: 'EPSI003',
        name: 'Anas Wayuu E.P.S.I.',
        regime: 'Especial',
      ),
    ];
  }

  /// Helper para crear EPSProvider con valores por defecto FHIR.
  static EPSProvider _eps({
    required String id,
    required String name,
    required String regime,
  }) {
    return EPSProvider(
      id: id,
      name: name,
      discoveryUrl: 'https://ihce.minsalud.gov.co/fhir/$id/.well-known/smart-configuration',
      revocationUrl: 'https://ihce.minsalud.gov.co/oauth/$id/revoke',
      clientId: 'orionhealth',
      redirectUrl: 'orionhealth://callback',
      scopes: const [
        'openid',
        'fhirUser',
        'patient/Patient.read',
        'patient/Observation.read',
        'patient/MedicationRequest.read',
        'patient/Condition.read',
        'patient/AllergyIntolerance.read',
        'patient/Immunization.read',
        'patient/Procedure.read',
        'patient/DiagnosticReport.read',
        'offline_access',
      ],
      type: EPSProviderType.fhir,
    );
  }

  /// Filtrar EPS por régimen.
  static List<EPSProvider> byRegime(String regime) {
    return activeProviders
        .where((p) => p.name.contains(regime))
        .toList();
  }

  /// Buscar EPS por nombre o ID.
  static List<EPSProvider> search(String query) {
    final q = query.toLowerCase();
    return activeProviders.where((p) {
      return p.name.toLowerCase().contains(q) ||
          p.id.toLowerCase().contains(q);
    }).toList();
  }

  /// Obtener una EPS por su ID.
  static EPSProvider? byId(String id) {
    try {
      return activeProviders.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Total de EPS en el catálogo.
  static int get count => activeProviders.length;

  /// IDs de todas las EPS.
  static List<String> get ids =>
      activeProviders.map((p) => p.id).toSet().toList()..sort();
}
