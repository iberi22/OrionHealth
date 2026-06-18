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
      );
      const p2 = EPSProvider(
        id: '1',
        name: 'N',
        discoveryUrl: 'D',
        clientId: 'C',
        redirectUrl: 'R',
        scopes: ['S'],
      );
      expect(p1, p2);
    });
  });
}
