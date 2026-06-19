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
  });
}
