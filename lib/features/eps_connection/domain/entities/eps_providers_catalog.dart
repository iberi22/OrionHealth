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

import '../../domain/entities/eps_provider.dart';

/// Catálogo oficial de EPS activas en Colombia (2026).
class EpsProvidersCatalog {
  EpsProvidersCatalog._();

  /// Lista completa de EPS activas en Colombia según REPS.
  static List<EPSProvider> get activeProviders => [
        // Régimen Contributivo y Subsidiado
        const EPSProvider(
          name: 'E.P.S. SURA',
          providerId: 'EPS025',
          regime: 'Contributivo',
          code: 'EPS025',
        ),
        const EPSProvider(
          name: 'Compensar E.P.S.',
          providerId: 'EPS008',
          regime: 'Contributivo',
          code: 'EPS008',
        ),
        const EPSProvider(
          name: 'Sanitas E.P.S.',
          providerId: 'EPS005',
          regime: 'Contributivo',
          code: 'EPS005',
        ),
        const EPSProvider(
          name: 'Nueva EPS',
          providerId: 'EPS037',
          regime: 'Contributivo',
          code: 'EPS037',
        ),
        const EPSProvider(
          name: 'Salud Total E.P.S.',
          providerId: 'EPS002',
          regime: 'Contributivo',
          code: 'EPS002',
        ),
        const EPSProvider(
          name: 'Famisanar E.P.S.',
          providerId: 'EPS017',
          regime: 'Contributivo',
          code: 'EPS017',
        ),
        const EPSProvider(
          name: 'Alianza Medellín Antioquia E.P.S. S.A.S.',
          providerId: 'EPS044',
          regime: 'Contributivo',
          code: 'EPS044',
        ),
        const EPSProvider(
          name: 'Savia Salud E.P.S.',
          providerId: 'EPS045',
          regime: 'Contributivo',
          code: 'EPS045',
        ),
        const EPSProvider(
          name: 'Salud Bolívar E.P.S. S.A.S.',
          providerId: 'EPS042',
          regime: 'Contributivo',
          code: 'EPS042',
        ),
        const EPSProvider(
          name: 'Cruz Blanca E.P.S. S.A.',
          providerId: 'EPS043',
          regime: 'Contributivo',
          code: 'EPS043',
        ),
        const EPSProvider(
          name: 'Mutual SER E.S.S.',
          providerId: 'EPS033',
          regime: 'Subsidiado',
          code: 'EPS033',
        ),
        const EPSProvider(
          name: 'Comfamiliar Huila E.P.S.',
          providerId: 'EPS012',
          regime: 'Subsidiado',
          code: 'EPS012',
        ),
        const EPSProvider(
          name: 'Comfenalco Valle E.P.S.',
          providerId: 'EPS010',
          regime: 'Subsidiado',
          code: 'EPS010',
        ),
        const EPSProvider(
          name: 'Mallamas E.P.S.I.',
          providerId: 'EPSI005',
          regime: 'Especial',
          code: 'EPSI005',
        ),
        const EPSProvider(
          name: 'Anas Wayuu E.P.S.I.',
          providerId: 'EPSI003',
          regime: 'Especial',
          code: 'EPSI003',
        ),
      ];

  /// Filtrar EPS por régimen.
  static List<EPSProvider> byRegime(String regime) {
    return activeProviders
        .where((p) => p.regime.toLowerCase() == regime.toLowerCase())
        .toList();
  }

  /// Buscar EPS por nombre o código.
  static List<EPSProvider> search(String query) {
    final q = query.toLowerCase();
    return activeProviders.where((p) {
      return p.name.toLowerCase().contains(q) ||
          p.providerId.toLowerCase().contains(q) ||
          p.code.toLowerCase().contains(q);
    }).toList();
  }

  /// Obtener una EPS por su código.
  static EPSProvider? byCode(String code) {
    try {
      return activeProviders.firstWhere((p) => p.code == code);
    } catch (_) {
      return null;
    }
  }

  /// Obtener una EPS por su providerId.
  static EPSProvider? byProviderId(String providerId) {
    try {
      return activeProviders.firstWhere((p) => p.providerId == providerId);
    } catch (_) {
      return null;
    }
  }

  /// Total de EPS en el catálogo.
  static int get count => activeProviders.length;

  /// Regímenes disponibles.
  static List<String> get regimes =>
      activeProviders.map((p) => p.regime).toSet().cast<String>().toList()..sort();
}
