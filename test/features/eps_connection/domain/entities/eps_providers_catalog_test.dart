import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/eps_connection/domain/entities/eps_provider.dart';
import 'package:orionhealth_health/features/eps_connection/domain/entities/eps_providers_catalog.dart';

void main() {
  group('EpsProvidersCatalog', () {
    test('activeProviders should not be empty', () {
      final providers = EpsProvidersCatalog.activeProviders;
      expect(providers.isNotEmpty, true);
      expect(EpsProvidersCatalog.count, greaterThanOrEqualTo(15));
    });

    test('all providers have required fields', () {
      for (final provider in EpsProvidersCatalog.activeProviders) {
        expect(provider.name.isNotEmpty, true, reason: '${provider.providerId} has no name');
        expect(provider.providerId.isNotEmpty, true, reason: '${provider.name} has no providerId');
        expect(provider.code.isNotEmpty, true, reason: '${provider.name} has no code');
        expect(provider.regime.isNotEmpty, true, reason: '${provider.name} has no regime');
      }
    });

    test('byRegime should filter correctly', () {
      final contributivo = EpsProvidersCatalog.byRegime('Contributivo');
      expect(contributivo.length, greaterThanOrEqualTo(5));
      for (final p in contributivo) {
        expect(p.regime, 'Contributivo');
      }

      final subsidiado = EpsProvidersCatalog.byRegime('Subsidiado');
      expect(subsidiado.length, greaterThanOrEqualTo(3));
      for (final p in subsidiado) {
        expect(p.regime, 'Subsidiado');
      }
    });

    test('search should find EPS by name', () {
      final results = EpsProvidersCatalog.search('SURA');
      expect(results.length, 1);
      expect(results.first.providerId, 'EPS025');
    });

    test('search should find EPS by code', () {
      final results = EpsProvidersCatalog.search('EPS005');
      expect(results.length, 1);
      expect(results.first.name, 'Sanitas E.P.S.');
    });

    test('search should be case insensitive', () {
      final upper = EpsProvidersCatalog.search('COMPENSAR');
      final lower = EpsProvidersCatalog.search('compensar');
      expect(upper.length, lower.length);
    });

    test('search should return empty for non-existent EPS', () {
      expect(EpsProvidersCatalog.search('XYZNoExiste'), isEmpty);
    });

    test('byCode should find by exact code', () {
      final eps = EpsProvidersCatalog.byCode('EPS037');
      expect(eps, isNotNull);
      expect(eps!.name, 'Nueva EPS');
    });

    test('byCode should return null for invalid code', () {
      expect(EpsProvidersCatalog.byCode('INVALID'), isNull);
    });

    test('byProviderId should find by exact providerId', () {
      final eps = EpsProvidersCatalog.byProviderId('EPS002');
      expect(eps, isNotNull);
      expect(eps!.name, 'Salud Total E.P.S.');
    });

    test('regimes should list unique regimes sorted', () {
      final regimes = EpsProvidersCatalog.regimes;
      expect(regimes.contains('Contributivo'), true);
      expect(regimes.contains('Subsidiado'), true);
      expect(regimes, equals(regimes.toSet().toList()..sort()));
    });

    test('providerIds should be unique', () {
      final ids = EpsProvidersCatalog.activeProviders.map((p) => p.providerId).toList();
      expect(ids.length, ids.toSet().length);
    });
  });
}
