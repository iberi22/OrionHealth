// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/onboarding/presentation/widgets/eps_info_modal.dart';
import '../../../../core/golden_test_utils.dart';

void main() {
  group('EpsInfoModal Widget Tests', () {
    testWidgets('renders all sections correctly', (WidgetTester tester) async {
      await tester.pumpWidget(wrapWithMaterial(const EpsInfoModal()));

      // Verify title
      expect(find.text('Conectar mi EPS'), findsOneWidget);

      // Verify sections
      expect(find.text('🔐 ¿Qué es la conexión EPS?'), findsOneWidget);
      expect(find.text('⚙️ ¿Cómo funciona?'), findsOneWidget);
      expect(find.text('🔄 Persistencia de sesión'), findsOneWidget);
      expect(find.text('📋 ¿Cómo usarla?'), findsOneWidget);
      expect(find.text('💡 Mantener la conexión'), findsOneWidget);

      // Verify Entendido button
      expect(find.text('Entendido'), findsOneWidget);
    });

    testWidgets('close icon button dismisses dialog', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => EpsInfoModal.show(context),
                child: const Text('Show'),
              ),
            ),
          ),
        ),
      );

      // Open dialog
      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      expect(find.byType(EpsInfoModal), findsOneWidget);

      // Tap close icon
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.byType(EpsInfoModal), findsNothing);
    });

    testWidgets('Entendido button dismisses dialog', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => EpsInfoModal.show(context),
                child: const Text('Show'),
              ),
            ),
          ),
        ),
      );

      // Set a larger surface size to ensure the button is visible
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      // Open dialog
      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      expect(find.byType(EpsInfoModal), findsOneWidget);

      // Scroll to the bottom to make sure the button is clickable
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -500));
      await tester.pump();

      // Tap Entendido button
      await tester.tap(find.text('Entendido'));
      await tester.pumpAndSettle();

      expect(find.byType(EpsInfoModal), findsNothing);
    });
  });
}
