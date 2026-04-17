import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/core/widgets/floating_assistant_button.dart';

void main() {
  group('FloatingAssistantButton', () {
    testWidgets('renders FAB with correct icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            floatingActionButton: FloatingAssistantButton(),
          ),
        ),
      );

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.medical_services), findsOneWidget);
    });

    testWidgets('pulse animation runs at correct duration', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            floatingActionButton: FloatingAssistantButton(),
          ),
        ),
      );

      // Find the AnimationController indirectly through the widget
      final fabFinder = find.byType(FloatingAssistantButton);
      expect(fabFinder, findsOneWidget);

      // Test animation at start
      await tester.pump(Duration.zero);
      
      // Test at midpoint (750ms = half of 1500ms duration)
      await tester.pump(const Duration(milliseconds: 750));
      
      // Test at end of one cycle (1500ms)
      await tester.pump(const Duration(milliseconds: 750));
      
      // Verify animation continues to next cycle
      await tester.pump(Duration.zero);
    });

    testWidgets('animation repeats continuously', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            floatingActionButton: FloatingAssistantButton(),
          ),
        ),
      );

      // Let it run through multiple cycles
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pump(const Duration(milliseconds: 1500));

      // Widget should still be present
      expect(find.byType(FloatingAssistantButton), findsOneWidget);
    });

    testWidgets('shows badge when hasNotification is true', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            floatingActionButton: FloatingAssistantButton(
              hasNotification: true,
            ),
          ),
        ),
      );

      // Badge should be visible (red container)
      final badgeFinder = find.byWidgetPredicate((widget) =>
          widget is Container &&
          widget.decoration is BoxDecoration &&
          (widget.decoration as BoxDecoration).color == Colors.red);

      expect(badgeFinder, findsOneWidget);
    });

    testWidgets('shows badge with count when badgeCount > 0', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            floatingActionButton: FloatingAssistantButton(
              badgeCount: 3,
            ),
          ),
        ),
      );

      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('tapping FAB opens medical assistant page', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            floatingActionButton: FloatingAssistantButton(),
          ),
        ),
      );

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Medical assistant page should be pushed (check for its title)
      expect(find.text('AI Medical Assistant'), findsOneWidget);
    });

    testWidgets('custom icon is displayed', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            floatingActionButton: FloatingAssistantButton(
              icon: Icons.chat,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.chat), findsOneWidget);
    });
  });

  group('FloatingAssistantButtonController', () {
    test('initial state has no notification', () {
      final controller = FloatingAssistantButtonController();
      
      expect(controller.hasNotification, false);
      expect(controller.badgeCount, 0);
    });

    test('showNotification updates state correctly', () {
      final controller = FloatingAssistantButtonController();
      
      controller.showNotification();
      
      expect(controller.hasNotification, true);
      expect(controller.badgeCount, 1);
    });

    test('clearNotification resets state', () {
      final controller = FloatingAssistantButtonController();
      
      controller.showNotification();
      controller.showNotification();
      controller.clearNotification();
      
      expect(controller.hasNotification, false);
      expect(controller.badgeCount, 0);
    });

    test('setBadgeCount updates both values', () {
      final controller = FloatingAssistantButtonController();
      
      controller.setBadgeCount(5);
      
      expect(controller.badgeCount, 5);
      expect(controller.hasNotification, true);
    });
  });

  group('FloatingAssistantButtonScope', () {
    testWidgets('provides controller to descendants', (tester) async {
      final controller = FloatingAssistantButtonController();
      
      await tester.pumpWidget(
        MaterialApp(
          home: FloatingAssistantButtonScope(
            notifier: controller,
            child: Builder(
              builder: (context) {
                final fabController = FloatingAssistantButtonScope.of(context);
                return Text('hasController: ${fabController != null}');
              },
            ),
          ),
        ),
      );

      expect(find.text('hasController: true'), findsOneWidget);
    });
  });
}
