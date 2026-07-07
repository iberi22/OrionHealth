import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/core/utils/connectivity_manager.dart';
import 'package:orionhealth_health/features/network/presentation/widgets/connection_status_badge.dart';

void main() {
  group('ConnectionStatusBadge', () {
    testWidgets('shows ONLINE status correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ConnectionStatusBadge(
              initialStatus: ConnectivityStatus.connected,
            ),
          ),
        ),
      );

      expect(find.text('ONLINE'), findsOneWidget);
      expect(find.byIcon(Icons.wifi), findsOneWidget);

      final container = tester.widget<Container>(
        find.ancestor(
          of: find.text('ONLINE'),
          matching: find.byType(Container),
        ).first,
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border!.top.color, Colors.green);
    });

    testWidgets('shows OFFLINE status correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ConnectionStatusBadge(
              initialStatus: ConnectivityStatus.disconnected,
            ),
          ),
        ),
      );

      expect(find.text('OFFLINE'), findsOneWidget);
      expect(find.byIcon(Icons.wifi_off), findsOneWidget);

      final container = tester.widget<Container>(
        find.ancestor(
          of: find.text('OFFLINE'),
          matching: find.byType(Container),
        ).first,
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border!.top.color, Colors.red);
    });

    testWidgets('responds to connectivity changes', (tester) async {
      final controller = StreamController<ConnectivityStatus>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConnectionStatusBadge(
              initialStatus: ConnectivityStatus.disconnected,
              statusStream: controller.stream,
            ),
          ),
        ),
      );

      expect(find.text('OFFLINE'), findsOneWidget);

      controller.add(ConnectivityStatus.connected);
      await tester.pumpAndSettle();

      expect(find.text('ONLINE'), findsOneWidget);
      expect(find.byIcon(Icons.wifi), findsOneWidget);

      controller.add(ConnectivityStatus.disconnected);
      await tester.pumpAndSettle();

      expect(find.text('OFFLINE'), findsOneWidget);
      expect(find.byIcon(Icons.wifi_off), findsOneWidget);

      controller.close();
    });

    testWidgets('shows UNKNOWN status correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ConnectionStatusBadge(
              initialStatus: ConnectivityStatus.unknown,
            ),
          ),
        ),
      );

      expect(find.text('UNKNOWN'), findsOneWidget);
      expect(find.byIcon(Icons.help_outline), findsOneWidget);

      final container = tester.widget<Container>(
        find.ancestor(
          of: find.text('UNKNOWN'),
          matching: find.byType(Container),
        ).first,
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border!.top.color, Colors.grey);
    });
  });
}
