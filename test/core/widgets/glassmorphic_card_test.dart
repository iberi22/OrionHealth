// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/core/widgets/glassmorphic_card.dart';

void main() {
  group('GlassmorphicCard', () {
    testWidgets('renders child correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: GlassmorphicCard(child: Text('Card Content'))),
        ),
      );

      expect(find.text('Card Content'), findsOneWidget);
    });

    testWidgets('triggers onTap when tapped', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlassmorphicCard(
              onTap: () => tapped = true,
              child: const Text('Tappable Card'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Tappable Card'));
      expect(tapped, isTrue);
    });

    testWidgets('applies custom padding', (tester) async {
      const customPadding = EdgeInsets.all(32);
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GlassmorphicCard(
              padding: customPadding,
              child: Text('Padded Card'),
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      expect(container.padding, equals(customPadding));
    });

    testWidgets('renders without exceptions when containing a ListTile', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlassmorphicCard(
              child: ListTile(title: const Text('Test ListTile'), onTap: () {}),
            ),
          ),
        ),
      );

      // Verify that no exception was thrown and the ListTile is found
      expect(find.byType(GlassmorphicCard), findsOneWidget);
      expect(find.byType(ListTile), findsOneWidget);
      expect(find.text('Test ListTile'), findsOneWidget);
    });
  });
}
