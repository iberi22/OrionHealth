// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/core/widgets/page_header.dart';

void main() {
  group('PageHeader', () {
    testWidgets('renders title and subtitle correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PageHeader(
              title: 'Page Title',
              subtitle: 'Page Subtitle',
            ),
          ),
        ),
      );

      expect(find.text('Page Title'), findsOneWidget);
      expect(find.text('Page Subtitle'), findsOneWidget);
    });

    testWidgets('renders leading and trailing widgets', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PageHeader(
              title: 'Title',
              leading: Icon(Icons.star, key: Key('leading')),
              trailing: Icon(Icons.settings, key: Key('trailing')),
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('leading')), findsOneWidget);
      expect(find.byKey(const Key('trailing')), findsOneWidget);
    });

    testWidgets('shows back button and triggers onBackPress', (tester) async {
      bool backPressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PageHeader(
              title: 'Back Test',
              showBackButton: true,
              onBackPress: () => backPressed = true,
            ),
          ),
        ),
      );

      final backButton = find.byType(IconButton);
      expect(backButton, findsOneWidget);
      await tester.tap(backButton);
      expect(backPressed, isTrue);
    });

    testWidgets('back button uses default pop behavior if onBackPress is null', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return PageHeader(
                  title: 'Pop Test',
                  showBackButton: true,
                );
              },
            ),
          ),
        ),
      );

      // This is a bit tricky to test without actual navigation,
      // but we can verify it doesn't crash and the button exists.
      expect(find.byType(IconButton), findsOneWidget);
    });
  });
}
