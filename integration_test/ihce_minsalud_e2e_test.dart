import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:orionhealth_health/features/eps_connection/domain/entities/eps_providers_catalog.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('IHCE Minsalud E2E', () {
    test('should list EPS providers from catalog', () {
      final providers = EpsProvidersCatalog.providers;
      expect(providers, isNotEmpty);
      expect(providers.length, greaterThan(0));
    });

    test('should get portal URL for EPS Sura', () {
      final url = EpsProvidersCatalog.getPortalUrl('EPS025');
      expect(url, isNotNull);
      expect(url, contains('sura'));
    });

    test('should get portal URL for all known EPS', () {
      final ids = ['EPS020', 'EPS037', 'EPS005', 'EPS025', 'EPS002', 'EPS008', 'EPS017'];
      for (final id in ids) {
        final url = EpsProvidersCatalog.getPortalUrl(id);
        expect(url, isNotNull);
        expect(url, isNotEmpty);
      }
    });

    test('unknown EPS should get IHCE sandbox fallback', () {
      final url = EpsProvidersCatalog.getPortalUrl('EPS999');
      expect(url, contains('sandbox.ihcecol.gov.co'));
    });
  });
}
