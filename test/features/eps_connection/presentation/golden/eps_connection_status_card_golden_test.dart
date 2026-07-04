import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/eps_connection/presentation/widgets/eps_connection_status_card.dart';
import 'package:orionhealth_health/features/eps_connection/domain/entities/eps_connection.dart';
import 'package:orionhealth_health/features/eps_connection/domain/entities/eps_provider.dart';
import 'package:orionhealth_health/features/eps_connection/domain/entities/oauth_token.dart';
import '../../../../core/golden_test_utils.dart';

void main() {
  group('EpsConnectionStatusCard Golden Tests', () {
    final connection = EPSConnection(
      provider: const EPSProvider(
        id: 'ihce-1',
        name: 'IHCE',
        discoveryUrl: 'https://example.com/auth',
        revocationUrl: 'https://example.com/revoke',
        clientId: 'client-id',
        redirectUrl: 'com.example.app://oauth',
        scopes: ['openid', 'profile'],
      ),
      token: const OAuthToken(accessToken: 'dummy-token'),
      patientId: 'PAT-12345',
      connectedAt: DateTime(2025, 1, 1, 10, 30),
    );

    testWidgets('EpsConnectionStatusCard - Default', (tester) async {
      setupGoldenTest(tester);

      await tester.pumpWidget(
        wrapWithMaterial(
          Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: EpsConnectionStatusCard(
                  connection: connection,
                  onDisconnect: () {},
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(EpsConnectionStatusCard),
        matchesGoldenFile("../../../../golden/reference/eps_connection_status_card.png"),
      );
      resetGoldenTest(tester);
    });
  });
}
