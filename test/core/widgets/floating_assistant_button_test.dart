import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/core/widgets/floating_assistant_button.dart';

Widget _buildTestApp(Widget fab) {
  return MaterialApp(
    home: Scaffold(
      floatingActionButton: fab,
    ),
  );
}

void main() {
  // Run widget-less controller tests in their own group first — no animation leaks.
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
                final ctrl = FloatingAssistantButtonScope.of(context);
                return Text('hasController: ${ctrl != null}');
              },
            ),
          ),
        ),
      );
      expect(find.text('hasController: true'), findsOneWidget);
    });
  });

  // Widget tests — each one must clean up the AnimationController.
  group('FloatingAssistantButton', () {
    testWidgets('renders FAB with correct icon', (tester) async {
      await tester.pumpWidget(_buildTestApp(const FloatingAssistantButton()));
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.medical_services), findsOneWidget);
      addTearDown(() => tester.binding.reset());
    });

    testWidgets('shows badge when hasNotification is true', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(const FloatingAssistantButton(hasNotification: true)),
      );
      final badgeFinder = find.byWidgetPredicate((w) =>
          w is Container &&
          w.decoration is BoxDecoration &&
          (w.decoration as BoxDecoration).color == Colors.red);
      expect(badgeFinder, findsOneWidget);
      addTearDown(() => tester.binding.reset());
    });

    testWidgets('shows badge with count when badgeCount > 0', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(const FloatingAssistantButton(badgeCount: 3)),
      );
      expect(find.text('3'), findsOneWidget);
      addTearDown(() => tester.binding.reset());
    });

    testWidgets('custom icon is displayed', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(const FloatingAssistantButton(icon: Icons.chat)),
      );
      expect(find.byIcon(Icons.chat), findsOneWidget);
      addTearDown(() => tester.binding.reset());
    });
  });
}
