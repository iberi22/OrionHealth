import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/eps_connection/domain/entities/eps_connection.dart';
import 'package:orionhealth_health/features/eps_connection/domain/entities/eps_provider.dart';
import 'package:orionhealth_health/features/eps_connection/domain/entities/oauth_token.dart';
import 'package:orionhealth_health/features/eps_connection/presentation/widgets/eps_connection_status_card.dart';

void main() {
  final testProvider = EPSProvider(
    id: 'id',
    name: 'Test Provider',
    discoveryUrl: 'url',
    clientId: 'client',
    redirectUrl: 'redir',
    scopes: const ['scope'],
  );
  final testToken = const OAuthToken(accessToken: 'token');
  final testConnection = EPSConnection(
    provider: testProvider,
    token: testToken,
    patientId: 'PT-123',
    connectedAt: DateTime(2023, 1, 1),
  );

  testWidgets('EpsConnectionStatusCard displays provider name and patient ID', (tester) async {
    bool disconnected = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EpsConnectionStatusCard(
            connection: testConnection,
            onDisconnect: () => disconnected = true,
          ),
        ),
      ),
    );

    expect(find.text('Test Provider'), findsOneWidget);
    expect(find.text('Patient ID: PT-123'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.link_off));
    expect(disconnected, true);
  });
}
