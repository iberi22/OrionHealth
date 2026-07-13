import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/eps_connection/domain/entities/eps_provider.dart';
import 'package:orionhealth_health/features/eps_connection/domain/entities/eps_providers_catalog.dart';

void main() {
  group('EpsProvidersCatalog — Colombia Completo', () {
    // ─── Catálogo completo ──────────────────────────────────

    test('debe tener las 28 EPS autorizadas por Minsalud', () {
      expect(EpsProvidersCatalog.count, 28,
          reason: 'Colombia tiene 28 EPS activas según Minsalud Julio 2026');
    });

    test('activeProviders no está vacío y tiene estructura correcta', () {
      final providers = EpsProvidersCatalog.activeProviders;
      expect(providers.isNotEmpty, true);
      expect(EpsProvidersCatalog.count, greaterThanOrEqualTo(28));
    });

    // ─── Validación de campos ───────────────────────────────

    test('todas las EPS tienen campos requeridos completos', () {
      for (final provider in EpsProvidersCatalog.todas) {
        expect(provider.id.isNotEmpty, true,
            reason: '${provider.name} no tiene id');
        expect(provider.name.isNotEmpty, true,
            reason: '${provider.id} no tiene nombre');
        expect(provider.discoveryUrl.isNotEmpty, true,
            reason: '${provider.name} no tiene discoveryUrl');
        expect(provider.clientId.isNotEmpty, true,
            reason: '${provider.name} no tiene clientId');
        expect(provider.redirectUrl.isNotEmpty, true,
            reason: '${provider.name} no tiene redirectUrl');
        expect(provider.scopes.isNotEmpty, true,
            reason: '${provider.name} no tiene scopes');
        expect(provider.type, EPSProviderType.fhir,
            reason: '${provider.name} debe ser tipo FHIR');
      }
    });

    test('los IDs son únicos', () {
      final ids = EpsProvidersCatalog.todas.map((p) => p.id).toList();
      expect(ids.length, ids.toSet().length,
          reason: 'No debe haber IDs duplicados');
    });

    test('todos los discoveryUrl apuntan a la plataforma IHCE', () {
      for (final provider in EpsProvidersCatalog.todas) {
        expect(
          provider.discoveryUrl,
          contains('ihce.minsalud.gov.co'),
          reason: '${provider.name} debe usar plataforma IHCE Minsalud',
        );
      }
    });

    // ─── Catálogo por régimen ───────────────────────────────

    test('debe tener 4 EPS en ambos regímenes', () {
      expect(EpsProvidersCatalog.ambosRegimenes.length, 4);
      final names = EpsProvidersCatalog.ambosRegimenes.map((p) => p.name);
      expect(names, contains('Coosalud EPS-S'));
      expect(names, contains('Nueva EPS'));
      expect(names, contains('Mutual SER E.S.S.'));
      expect(names, contains('Salud MIA EPS'));
    });

    test('debe tener 10 EPS en régimen contributivo', () {
      expect(EpsProvidersCatalog.soloContributivo.length, 10);
      final names = EpsProvidersCatalog.soloContributivo.map((p) => p.name);
      expect(names, contains('EPS SURA'));
      expect(names, contains('Compensar EPS'));
      expect(names, contains('EPS Sanitas S.A.S.'));
      expect(names, contains('Salud Total EPS S.A.'));
      expect(names, contains('Famisanar S.A.S.'));
    });

    test('debe tener 14 EPS en régimen subsidiado + EPSI', () {
      // 9 subsidiado + 5 EPSI = 14
      expect(EpsProvidersCatalog.soloSubsidiado.length, 14);
    });

    test('byRegime("contributivo") incluye ambos + contributivo', () {
      final contributivo = EpsProvidersCatalog.byRegime('contributivo');
      // 4 ambos + 10 contributivo = 14
      expect(contributivo.length, 14);
    });

    test('byRegime("subsidiado") incluye ambos + subsidiado', () {
      final subsidiado = EpsProvidersCatalog.byRegime('subsidiado');
      // 4 ambos + 14 subsidiado = 18
      expect(subsidiado.length, 18);
    });

    // ─── Búsqueda ───────────────────────────────────────────

    test('search encuentra EPS por nombre exacto', () {
      expect(EpsProvidersCatalog.search('SURA').length, 1);
      expect(EpsProvidersCatalog.search('SURA').first.id, 'EPS025');
    });

    test('search encuentra EPS por nombre parcial', () {
      final results = EpsProvidersCatalog.search('Salud');
      expect(results.length, greaterThanOrEqualTo(3));
      final names = results.map((p) => p.name);
      expect(names, contains('Salud Total EPS S.A.'));
      expect(names, contains('Salud MIA EPS'));
    });

    test('search encuentra por ID', () {
      expect(EpsProvidersCatalog.search('EPS037').length, 1);
      expect(EpsProvidersCatalog.search('EPS037').first.name, 'Nueva EPS');
    });

    test('search es case-insensitive', () {
      final upper = EpsProvidersCatalog.search('COMPENSAR');
      final lower = EpsProvidersCatalog.search('compensar');
      expect(upper.length, lower.length);
      expect(upper.length, greaterThanOrEqualTo(1));
    });

    test('search para EPS inexistente retorna vacío', () {
      expect(EpsProvidersCatalog.search('XYZNoExiste'), isEmpty);
    });

    test('search encuentra EPSI indígenas', () {
      expect(EpsProvidersCatalog.search('Wayuu').length, 1);
      expect(EpsProvidersCatalog.search('Wayuu').first.id, 'EPSI003');
    });

    // ─── Lookup por ID ──────────────────────────────────────

    test('byId encuentra EPS por ID exacto', () {
      final eps = EpsProvidersCatalog.byId('EPS037');
      expect(eps, isNotNull);
      expect(eps!.name, 'Nueva EPS');
    });

    test('byId retorna null para ID inválido', () {
      expect(EpsProvidersCatalog.byId('EPS999'), isNull);
    });

    test('byId funciona con IDs de EPSI', () {
      final eps = EpsProvidersCatalog.byId('EPSI001');
      expect(eps, isNotNull);
      expect(eps!.name, contains('Dusakawi'));
    });

    // ─── Utilidades ─────────────────────────────────────────

    test('ids retorna lista ordenada sin duplicados', () {
      final ids = EpsProvidersCatalog.ids;
      expect(ids.length, EpsProvidersCatalog.count);
      expect(ids, equals(ids.toSet().toList()..sort()));
    });

    test('names retorna lista ordenada alfabéticamente', () {
      final names = EpsProvidersCatalog.names;
      expect(names, equals(names.toList()..sort()));
    });

    test('prettyPrint genera texto legible', () {
      final text = EpsProvidersCatalog.prettyPrint();
      expect(text, contains('28 activas'));
      expect(text, contains('Ambos regímenes'));
      expect(text, contains('Contributivo'));
      expect(text, contains('Subsidiado + EPSI'));
      expect(text, contains('EPS SURA'));
      expect(text, contains('Anas Wayuu EPSI'));
    });

    // ─── EPSI ───────────────────────────────────────────────

    test('catálogo incluye las 5 EPSI indígenas', () {
      final epsiNames = EpsProvidersCatalog.search('EPSI')
          .map((p) => p.name)
          .toList();
      expect(epsiNames, contains('Dusakawi EPSI'));
      expect(epsiNames, contains('Asoc. Indígena del Cauca — AIC EPSI'));
      expect(epsiNames, contains('Anas Wayuu EPSI'));
      expect(epsiNames, contains('Mallamas EPSI'));
      expect(epsiNames, contains('Pijaos Salud EPSI'));
    });
  });
}
