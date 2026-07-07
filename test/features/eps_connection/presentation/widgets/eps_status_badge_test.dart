import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/eps_connection/presentation/widgets/eps_status_badge.dart';

void main() {
  group('EpsStatusBadge', () {
    testWidgets('shows CONECTADO status correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EpsStatusBadge(
              status: EpsStatus.connected,
            ),
          ),
        ),
      );

      expect(find.text('CONECTADO'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);

      final container = tester.widget<Container>(
        find.ancestor(
          of: find.text('CONECTADO'),
          matching: find.byType(Container),
        ).first,
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border!.top.color, Colors.green);
    });

    testWidgets('shows DESCONECTADO status correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EpsStatusBadge(
              status: EpsStatus.disconnected,
            ),
          ),
        ),
      );

      expect(find.text('DESCONECTADO'), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsOneWidget);

      final container = tester.widget<Container>(
        find.ancestor(
          of: find.text('DESCONECTADO'),
          matching: find.byType(Container),
        ).first,
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border!.top.color, Colors.grey);
    });

    testWidgets('shows ERROR status correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EpsStatusBadge(
              status: EpsStatus.error,
            ),
          ),
        ),
      );

      expect(find.text('ERROR'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);

      final container = tester.widget<Container>(
        find.ancestor(
          of: find.text('ERROR'),
          matching: find.byType(Container),
        ).first,
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border!.top.color, Colors.red);
    });
  });
}
