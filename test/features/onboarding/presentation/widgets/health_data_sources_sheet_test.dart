// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/onboarding/presentation/widgets/health_data_sources_sheet.dart';
import 'package:orionhealth_health/features/onboarding/domain/entities/health_data_source.dart';
import '../../../../core/golden_test_utils.dart';

void main() {
  group('HealthDataSourcesSheet Widget Tests', () {
    testWidgets('renders header and all 10 sources', (WidgetTester tester) async {
      await tester.pumpWidget(wrapWithMaterial(const HealthDataSourcesSheet()));

      // Verify header
      expect(find.text('Sincronizar datos de salud'), findsOneWidget);
      expect(find.text('Conectá tus apps deportivas y de salud'), findsOneWidget);

      // Verify sources are rendered
      final sources = HealthDataSourcesCatalog.all;
      expect(sources.length, 10);

      for (final source in sources) {
        await tester.dragUntilVisible(
          find.text(source.name),
          find.byType(ListView),
          const Offset(0, -100),
        );
        // Find by text and filter to ensure it's the title
        expect(find.widgetWithText(Column, source.name), findsAtLeast(1));
      }
    });

    testWidgets('shows data type chips for Google Fit', (WidgetTester tester) async {
      await tester.pumpWidget(wrapWithMaterial(const HealthDataSourcesSheet()));

      await tester.dragUntilVisible(
        find.text('Google Fit'),
        find.byType(ListView),
        const Offset(0, -100),
      );

      // Find the specific card for Google Fit
      final googleFitSource = HealthDataSourcesCatalog.byId('google_fit')!;
      final googleFitCard = find.ancestor(
        of: find.text(googleFitSource.description),
        matching: find.byType(InkWell),
      ).first;

      expect(find.descendant(of: googleFitCard, matching: find.text('pasos')), findsOneWidget);
      expect(find.descendant(of: googleFitCard, matching: find.text('ritmo cardíaco')), findsOneWidget);
      expect(find.descendant(of: googleFitCard, matching: find.text('calorías')), findsOneWidget);
      expect(find.descendant(of: googleFitCard, matching: find.text('sueño')), findsOneWidget);
    });

    testWidgets('connect and disconnect toggle works', (WidgetTester tester) async {
      HealthDataSource? connectedSource;
      await tester.pumpWidget(wrapWithMaterial(
        HealthDataSourcesSheet(
          onSourceConnected: (s) => connectedSource = s,
        ),
      ));

      // Find Strava card
      await tester.dragUntilVisible(
        find.text('Strava'),
        find.byType(ListView),
        const Offset(0, -100),
      );

      final stravaSource = HealthDataSourcesCatalog.byId('strava')!;
      final stravaCard = find.ancestor(
        of: find.text(stravaSource.description),
        matching: find.byType(InkWell),
      ).first;

      final stravaConnect = find.descendant(
        of: stravaCard,
        matching: find.text('Conectar'),
      );

      await tester.tap(stravaConnect);
      await tester.pump(); // Start loading

      // Verify loading state - ONLY for Strava
      expect(find.descendant(of: stravaCard, matching: find.byType(CircularProgressIndicator)), findsOneWidget);

      // Wait for simulation (1s)
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();

      // Verify connected state
      expect(connectedSource?.id, 'strava');
      expect(find.descendant(of: stravaCard, matching: find.byIcon(Icons.check_circle)), findsOneWidget);

      // Verify buttons changed
      expect(find.text('Continuar'), findsOneWidget);
      expect(find.text('Listo'), findsOneWidget);
      expect(find.text('1/10'), findsOneWidget);

      // Disconnect
      await tester.tap(find.descendant(of: stravaCard, matching: find.byIcon(Icons.check_circle)));
      await tester.pump();

      // Verify disconnected state
      expect(find.descendant(of: stravaCard, matching: find.text('Conectar')), findsOneWidget);
      expect(find.text('Omitir'), findsOneWidget);
      expect(find.text('Más tarde'), findsOneWidget);
    });

    testWidgets('empty state shows Omitir/Más tarde', (WidgetTester tester) async {
      await tester.pumpWidget(wrapWithMaterial(const HealthDataSourcesSheet()));

      expect(find.text('Omitir'), findsOneWidget);
      expect(find.text('Más tarde'), findsOneWidget);
    });
  });
}
