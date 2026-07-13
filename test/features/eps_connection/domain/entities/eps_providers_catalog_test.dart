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
        expect(provider.id.isNotEmpty, true, reason: '${provider.name} has no id');
        expect(provider.name.isNotEmpty, true, reason: '${provider.id} has no name');
        expect(provider.discoveryUrl.isNotEmpty, true, reason: '${provider.name} has no discoveryUrl');
        expect(provider.clientId.isNotEmpty, true, reason: '${provider.name} has no clientId');
        expect(provider.redirectUrl.isNotEmpty, true, reason: '${provider.name} has no redirectUrl');
        expect(provider.scopes.isNotEmpty, true, reason: '${provider.name} has no scopes');
        expect(provider.type, EPSProviderType.fhir, reason: '${provider.name} should be FHIR type');
      }
    });

    test('search should find EPS by name', () {
      final results = EpsProvidersCatalog.search('SURA');
      expect(results.length, 1);
      expect(results.first.id, 'EPS025');
    });

    test('search should find EPS by id', () {
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

    test('byId should find by exact id', () {
      final eps = EpsProvidersCatalog.byId('EPS037');
      expect(eps, isNotNull);
      expect(eps!.name, 'Nueva EPS');
    });

    test('byId should return null for invalid id', () {
      expect(EpsProvidersCatalog.byId('INVALID'), isNull);
    });

    test('ids should list all unique ids sorted', () {
      final ids = EpsProvidersCatalog.ids;
      expect(ids.length, EpsProvidersCatalog.count);
      expect(ids, equals(ids.toSet().toList()..sort()));
    });

    test('ids should be unique', () {
      final ids = EpsProvidersCatalog.activeProviders.map((p) => p.id).toList();
      expect(ids.length, ids.toSet().length);
    });

    test('discoveryUrls all point to IHCE platform', () {
      for (final provider in EpsProvidersCatalog.activeProviders) {
        expect(
          provider.discoveryUrl,
          contains('ihce.minsalud.gov.co'),
          reason: '${provider.name} should use IHCE platform',
        );
      }
    });
  });
}
