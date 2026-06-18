import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/eps_connection/domain/entities/eps_connection.dart';
import 'package:orionhealth_health/features/eps_connection/domain/entities/eps_provider.dart';
import 'package:orionhealth_health/features/eps_connection/domain/entities/oauth_token.dart';

void main() {
  group('EPSConnection', () {
    test('supports value equality', () {
      final now = DateTime.now();
      const provider = EPSProvider(
        id: '1',
        name: 'N',
        discoveryUrl: 'D',
        clientId: 'C',
        redirectUrl: 'R',
        scopes: ['S'],
      );
      final token = OAuthToken(accessToken: 'A', expiresAt: now);

      final c1 = EPSConnection(provider: provider, token: token, patientId: 'P', connectedAt: now);
      final c2 = EPSConnection(provider: provider, token: token, patientId: 'P', connectedAt: now);

      expect(c1, c2);
    });
  });
}
