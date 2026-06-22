// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/core/widgets/connection_status_indicator.dart';

void main() {
  group('ConnectionStatusIndicator', () {
    testWidgets('renders correctly for each status', (tester) async {
      for (final status in ConnectionStatus.values) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ConnectionStatusIndicator(status: status),
            ),
          ),
        );

        await tester.pump();

        // Verify it renders
        expect(find.byType(ConnectionStatusIndicator), findsOneWidget);

        // Verify status icon exists (via SmartIcon which uses Icon internally in tests)
        expect(find.byType(Icon), findsWidgets);
      }
    });

    testWidgets('displays custom message when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ConnectionStatusIndicator(
              status: ConnectionStatus.connected,
              customMessage: 'Custom Connected',
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.text('Custom Connected'), findsOneWidget);
    });

    testWidgets('hides label when showLabel is false', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ConnectionStatusIndicator(
              status: ConnectionStatus.connected,
              showLabel: false,
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.text('Conectado'), findsNothing);
    });

    testWidgets('triggers onTap callback', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConnectionStatusIndicator(
              status: ConnectionStatus.connected,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ConnectionStatusIndicator));
      expect(tapped, isTrue);
    });
  });

  group('LocalConnectionStatus', () {
    testWidgets('renders local AI and memory status correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LocalConnectionStatus(
              isLocalAIReady: true,
              isMemoryReady: false,
              memoryCount: 42,
            ),
          ),
        ),
      );

      expect(find.text('Estado del Sistema'), findsOneWidget);
      expect(find.text('IA Local (LM Studio)'), findsOneWidget);
      expect(find.text('Memoria Local (Isar)'), findsOneWidget);

      // Status texts
      expect(find.text('Conectado'), findsOneWidget);
      expect(find.text('No disponible'), findsOneWidget);
    });

    testWidgets('shows refresh button when onRetry is provided', (tester) async {
      bool retried = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LocalConnectionStatus(
              isLocalAIReady: true,
              isMemoryReady: true,
              onRetry: () => retried = true,
            ),
          ),
        ),
      );

      final refreshButton = find.byIcon(Icons.refresh);
      expect(refreshButton, findsOneWidget);
      await tester.tap(refreshButton);
      expect(retried, isTrue);
    });
  });
}
