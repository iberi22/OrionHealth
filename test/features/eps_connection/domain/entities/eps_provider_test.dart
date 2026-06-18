import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/eps_connection/domain/entities/eps_provider.dart';

void main() {
  group('EPSProvider', () {
    test('supports value equality', () {
      const p1 = EPSProvider(
        id: '1',
        name: 'N',
        discoveryUrl: 'D',
        clientId: 'C',
        redirectUrl: 'R',
        scopes: ['S'],
        type: EPSProviderType.ihce,
      );
      const p2 = EPSProvider(
        id: '1',
        name: 'N',
        discoveryUrl: 'D',
        clientId: 'C',
        redirectUrl: 'R',
        scopes: ['S'],
        type: EPSProviderType.ihce,
      );
      expect(p1, p2);
    });

    test('props contain all fields', () {
      const p = EPSProvider(
        id: '1',
        name: 'N',
        discoveryUrl: 'D',
        clientId: 'C',
        redirectUrl: 'R',
        scopes: ['S'],
        type: EPSProviderType.fhir,
      );
      expect(p.props, ['1', 'N', 'D', 'C', 'R', ['S'], EPSProviderType.fhir]);
    });
  });

  group('EPSProviderType', () {
    test('enum values', () {
      expect(EPSProviderType.values.length, 3);
      expect(EPSProviderType.ihce.name, 'ihce');
      expect(EPSProviderType.openmrs.name, 'openmrs');
      expect(EPSProviderType.fhir.name, 'fhir');
    });
  });
}
