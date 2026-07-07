import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/core/theme/app_colors.dart';
import 'package:orionhealth_health/features/local_agent/domain/entities/agent_status.dart';
import 'package:orionhealth_health/features/local_agent/presentation/widgets/agent_status_card.dart';

void main() {
  group('AgentStatusCard Widget Tests', () {
    testWidgets('renders agent name correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AgentStatusCard(
              agentName: 'Orion Assistant',
              status: AgentStatus.online,
            ),
          ),
        ),
      );

      expect(find.text('Orion Assistant'), findsOneWidget);
    });

    testWidgets('displays correct label and color for online status',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AgentStatusCard(
              agentName: 'Orion Assistant',
              status: AgentStatus.online,
            ),
          ),
        ),
      );

      expect(find.text('En línea'), findsOneWidget);

      final textWidget = tester.widget<Text>(find.text('En línea'));
      expect(textWidget.style?.color, AppColors.primary);
    });

    testWidgets('displays correct label and color for offline status',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AgentStatusCard(
              agentName: 'Orion Assistant',
              status: AgentStatus.offline,
            ),
          ),
        ),
      );

      expect(find.text('Desconectado'), findsOneWidget);

      final textWidget = tester.widget<Text>(find.text('Desconectado'));
      expect(textWidget.style?.color, Colors.grey);
    });

    testWidgets('displays correct label and color for busy status',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AgentStatusCard(
              agentName: 'Orion Assistant',
              status: AgentStatus.busy,
            ),
          ),
        ),
      );

      expect(find.text('En uso'), findsOneWidget);

      final textWidget = tester.widget<Text>(find.text('En uso'));
      expect(textWidget.style?.color, Colors.orangeAccent);
    });

    testWidgets('shows scale animation for online status',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AgentStatusCard(
              agentName: 'Orion Assistant',
              status: AgentStatus.online,
            ),
          ),
        ),
      );

      // Verify ScaleTransition is present
      final finder = find.byKey(const Key('agent_status_pulse'));
      expect(finder, findsOneWidget);

      // Get initial scale
      final scaleTransition = tester.widget<ScaleTransition>(finder);
      final initialScale = scaleTransition.scale.value;

      // Pump for some time
      await tester.pump(const Duration(seconds: 1));

      final midScale = scaleTransition.scale.value;
      expect(midScale, isNot(initialScale));
    });

    testWidgets('does not show scale animation for offline status',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AgentStatusCard(
              agentName: 'Orion Assistant',
              status: AgentStatus.offline,
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('agent_status_pulse')), findsNothing);
    });
  });
}
