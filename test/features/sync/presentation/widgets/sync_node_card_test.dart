import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/sync/domain/entities/sync_node.dart';
import 'package:orionhealth_health/features/sync/presentation/widgets/sync_node_card.dart';

void main() {
  group('SyncNodeCard', () {
    const node = SyncNode(
      id: '1',
      name: 'Test Node',
      host: '192.168.1.1',
      port: 8080,
    );

    testWidgets('renders node information correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SyncNodeCard(node: node),
          ),
        ),
      );

      expect(find.text('Test Node'), findsOneWidget);
      expect(find.text('192.168.1.1:8080'), findsOneWidget);
      expect(find.byIcon(Icons.router), findsOneWidget);
      expect(find.byIcon(Icons.sync), findsNothing);
    });

    testWidgets('calls onTap when provided and tapped', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SyncNodeCard(
              node: node,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.sync), findsOneWidget);
      await tester.tap(find.byType(SyncNodeCard));
      expect(tapped, isTrue);
    });

    testWidgets('handles long node names and hosts without overflow', (tester) async {
      const longNode = SyncNode(
        id: '1',
        name: 'A very long node name that might cause overflow if not handled correctly by the expanded widget',
        host: '192.168.100.200.very.long.hostname.example.com',
        port: 65535,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SyncNodeCard(node: longNode),
          ),
        ),
      );

      expect(find.text(longNode.name), findsOneWidget);
      expect(find.text('${longNode.host}:${longNode.port}'), findsOneWidget);
      // If there was an overflow, the test would typically fail or show a warning in a real flutter environment.
      // In widget tests, we verify the widgets are present.
    });
  });
}
