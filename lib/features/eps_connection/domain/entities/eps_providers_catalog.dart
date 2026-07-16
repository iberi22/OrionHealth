// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

/// Catálogo completo de Entidades Promotoras de Salud (EPS) de Colombia.
///
/// Fuente oficial: Ministerio de Salud y Protección Social de Colombia
/// - Registro Especial de Prestadores de Servicios de Salud (REPS)
/// - https://prestadores.minsalud.gov.co/habilitacion/
///
/// ═══════════════════════════════════════════════════════════════
/// DATOS REALES — Julio 2026
/// ═══════════════════════════════════════════════════════════════
/// Total de EPS autorizadas en Colombia: 28 (según Minsalud)
/// - Régimen contributivo y subsidiado: 4 EPS
/// - Régimen contributivo únicamente: 10 EPS
/// - Régimen subsidiado únicamente: 14 EPS
/// - EPS indígenas (EPSI): 3 (incluidas en subsidiado)
///
/// Interoperabilidad vía IHCE (Interoperabilidad de Historia Clínica
/// Electrónica) de Minsalud, que utiliza HL7 FHIR R4 como estándar
/// desde la Resolución 1888 de 2025, con implementación obligatoria
/// desde el 15 de abril de 2026.
///
/// OrionHealth se conecta a la API centralizada de IHCE Minsalud
/// como intermediario FHIR, no directamente a cada EPS individual.
///
/// ═══════════════════════════════════════════════════════════════
/// RÉGIMEN
/// ═══════════════════════════════════════════════════════════════
/// - Contributivo:   Trabajadores formales y sus familias
/// - Subsidiado:     Población sin capacidad de pago (Sisbén)
/// - Especial (EPSI): Comunidades indígenas

import 'eps_provider.dart';

/// Catálogo oficial de las 28 EPS activas en Colombia (Julio 2026).
class EpsProvidersCatalog {
  EpsProvidersCatalog._();

  // ─── Catálogo completo ─────────────────────────────────────

  /// Las 28 EPS autorizadas por Minsalud para operar en Colombia.
  static List<EPSProvider> get activeProviders => _buildAll();

  static List<EPSProvider> _buildAll() {
    return [
      ..._contributivoSubsidiado,
      ..._contributivo,
      ..._subsidiado,
    ];
  }

  // ─── Ambos regímenes (4 EPS) ───────────────────────────────

  static List<EPSProvider> get _contributivoSubsidiado => [
    _eps('EPS020', 'Coosalud EPS-S', 'Ambos'),
    _eps('EPS037', 'Nueva EPS', 'Ambos'),
    _eps('EPS033', 'Mutual SER E.S.S.', 'Ambos'),
    _eps('EPS050', 'Salud MIA EPS', 'Ambos'),
  ];

  // ─── Régimen contributivo (10 EPS) ─────────────────────────

  static List<EPSProvider> get _contributivo => [
    _eps('EPS001', 'Aliansalud EPS', 'Contributivo'),
    _eps('EPS002', 'Salud Total EPS S.A.', 'Contributivo'),
    _eps('EPS005', 'EPS Sanitas S.A.S.', 'Contributivo'),
    _eps('EPS025', 'EPS SURA', 'Contributivo'),
    _eps('EPS017', 'Famisanar S.A.S.', 'Contributivo'),
    _eps('EPS016', 'Servicio Occidental de Salud SOS', 'Contributivo'),
    _eps('EPS010', 'Comfenalco Valle EPS', 'Contributivo'),
    _eps('EPS008', 'Compensar EPS', 'Contributivo'),
    _eps('EPS035', 'EPM — Empresas Públicas de Medellín', 'Contributivo'),
    _eps('EPS046', 'Fondo Pasivo Social Ferrocarriles Nacionales', 'Contributivo'),
  ];

  // ─── Régimen subsidiado (14 EPS + 3 EPSI) ──────────────────

  static List<EPSProvider> get _subsidiado => [
    _eps('EPS003', 'Cajacopi Atlántico EPS-S', 'Subsidiado'),
    _eps('EPS007', 'Capresoca EPS-S', 'Subsidiado'),
    _eps('EPS004', 'Comfachocó EPS-S', 'Subsidiado'),
    _eps('EPS009', 'Comfaoriente EPS-S', 'Subsidiado'),
    _eps('EPS011', 'EPS Familiar de Colombia', 'Subsidiado'),
    _eps('EPS012', 'Asmet Salud EPS-S', 'Subsidiado'),
    _eps('EPS013', 'Emssanar E.S.S.', 'Subsidiado'),
    _eps('EPS015', 'Capital Salud EPS-S', 'Subsidiado'),
    _eps('EPS045', 'Savia Salud EPS', 'Subsidiado'),
    // EPS Indígenas (EPSI)
    _eps('EPSI001', 'Dusakawi EPSI', 'Especial (Indígena)'),
    _eps('EPSI002', 'Asoc. Indígena del Cauca — AIC EPSI', 'Especial (Indígena)'),
    _eps('EPSI003', 'Anas Wayuu EPSI', 'Especial (Indígena)'),
    _eps('EPSI004', 'Mallamas EPSI', 'Especial (Indígena)'),
    _eps('EPSI005', 'Pijaos Salud EPSI', 'Especial (Indígena)'),
  ];

  // ─── Builder ──────────────────────────────────────────────

  /// Crea un [EPSProvider] con configuración FHIR centralizada vía IHCE.
  static EPSProvider _eps(
    String id,
    String name,
    String regime,
  ) {
    return EPSProvider(
      id: id,
      name: name,
      discoveryUrl:
          'https://ihce.minsalud.gov.co/fhir/$id/.well-known/smart-configuration',
      revocationUrl: 'https://ihce.minsalud.gov.co/oauth/$id/revoke',
      clientId: '',
      redirectUrl: '',
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

  // ─── Queries ──────────────────────────────────────────────

  /// EPS que operan en régimen contributivo y subsidiado.
  static List<EPSProvider> get ambosRegimenes =>
      _contributivoSubsidiado;

  /// EPS solo régimen contributivo.
  static List<EPSProvider> get soloContributivo => _contributivo;

  /// EPS solo régimen subsidiado + EPSI.
  static List<EPSProvider> get soloSubsidiado => _subsidiado;

  /// Todas las EPS incluyendo EPSI indígenas.
  static List<EPSProvider> get todas => activeProviders;

  /// Filtrar EPS por régimen.
  static List<EPSProvider> byRegime(String regime) {
    final q = regime.toLowerCase();
    return activeProviders.where((p) {
      // Match parcial por nombre (cada EPS tiene su régimen en el nombre)
      if (q == 'contributivo') {
        return _contributivoSubsidiado.contains(p) ||
            _contributivo.contains(p);
      }
      if (q == 'subsidiado' || q == 'especial') {
        return _contributivoSubsidiado.contains(p) ||
            _subsidiado.contains(p);
      }
      if (q == 'ambos') {
        return _contributivoSubsidiado.contains(p);
      }
      return false;
    }).toList();
  }

  /// Buscar EPS por nombre o ID (case-insensitive).
  static List<EPSProvider> search(String query) {
    final q = query.toLowerCase();
    return activeProviders.where((p) {
      return p.name.toLowerCase().contains(q) ||
          p.id.toLowerCase().contains(q);
    }).toList();
  }

  /// Obtener una EPS por su ID exacto.
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

  /// Nombres de todas las EPS.
  static List<String> get names =>
      activeProviders.map((p) => p.name).toList()..sort();

  /// Lista de EPS como texto legible (para UI de selección).
  static String prettyPrint() {
    final buf = StringBuffer();
    buf.writeln('═══ EPS Colombia — Catálogo Oficial (${activeProviders.length} activas) ═══');
    buf.writeln();
    buf.writeln('── Ambos regímenes (${_contributivoSubsidiado.length}) ──');
    for (final eps in _contributivoSubsidiado) {
      buf.writeln('  $eps');
    }
    buf.writeln();
    buf.writeln('── Contributivo (${_contributivo.length}) ──');
    for (final eps in _contributivo) {
      buf.writeln('  $eps');
    }
    buf.writeln();
    buf.writeln('── Subsidiado + EPSI (${_subsidiado.length}) ──');
    for (final eps in _subsidiado) {
      buf.writeln('  $eps');
    }
    return buf.toString();
  }

  /// Obtiene la URL real del portal web de la EPS para autenticación vía WebView.
  static String getPortalUrl(String id) {
    switch (id) {
      case 'EPS020':
        return 'https://coosalud.com/';
      case 'EPS037':
        return 'https://www.nuevaeps.co/';
      case 'EPS005':
        return 'https://www.epssanitas.com/';
      case 'EPS025':
        return 'https://www.epssura.com/';
      case 'EPS002':
        return 'https://saludtotal.com.co/';
      case 'EPS008':
        return 'https://corporativo.compensar.com/salud';
      case 'EPS017':
        return 'https://www.famisanar.com.co/';
      default:
        // Fallback al sandbox en desarrollo
        return 'https://sandbox.ihcecol.gov.co/ihce';
    }
  }

  /// Obtiene la URL directa del formulario de login de la EPS.
  ///
  /// A diferencia de [getPortalUrl] que apunta a la homepage, esta URL
  /// carga directamente el formulario de inicio de sesión, ahorrando al
  /// usuario tener que navegar desde la index hasta el login.
  ///
  /// Si no hay URL de login específica, retorna null y se usa [getPortalUrl].
  static String? getLoginUrl(String id) {
    switch (id) {
      case 'EPS025': // Sura — SSO login directo
        return 'https://login.sura.com/sso/servicelogin.aspx'
            '?continueTo=https%3A%2F%2Fportaleps.epssura.com%2FServiciosUnClick%2F'
            '&service=epssura';
      case 'EPS005': // Sanitas — login directo
        return 'https://www.epssanitas.com/usuarios/login';
      case 'EPS037': // Nueva EPS — login directo
        return 'https://www.nuevaeps.co/login';
      case 'EPS002': // Salud Total
        return 'https://saludtotal.com.co/login';
      case 'EPS008': // Compensar
        return 'https://corporativo.compensar.com/salud/login';
      case 'EPS017': // Famisanar
        return 'https://www.famisanar.com.co/login';
      default:
        return null; // Usar getPortalUrl como fallback
    }
  }

  /// Retorna las URLs internas del portal EPS donde se encuentran los datos
  /// del paciente (perfil, historia clínica, medicamentos, etc).
  ///
  /// El auto-tour navega secuencialmente por estas páginas después del login
  /// para extraer la máxima cantidad de datos del paciente.
  static List<String> getTourUrls(String id) {
    switch (id) {
      case 'EPS025': // Sura — páginas de datos dentro del portal
        return [
          // Perfil / Datos del afiliado
          '/ServiciosUnClick/',
          // Intentar paths comunes de perfil
          '/perfil',
          '/datos-afiliado',
          '/mi-perfil',
        ];
      case 'EPS005': // Sanitas
        return ['/perfil', '/mi-perfil', '/datos'];
      case 'EPS037': // Nueva EPS
        return ['/perfil', '/mi-perfil', '/datos'];
      default:
        return ['/perfil', '/mi-perfil'];
    }
  }
}
