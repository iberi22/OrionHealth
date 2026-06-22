// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/core/widgets/volume_level_indicator.dart';

void main() {
  group('VolumeLevelIndicator', () {
    testWidgets('renders circular style correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VolumeLevelIndicator(
              isActive: false,
              volumeLevel: 0.5,
              style: VolumeIndicatorStyle.circular,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(CustomPaint), findsWidgets);
      expect(find.text('50%'), findsOneWidget);
      expect(find.text('Good'), findsOneWidget);
    });

    testWidgets('renders linear style correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VolumeLevelIndicator(
              isActive: true,
              volumeLevel: 0.2,
              style: VolumeIndicatorStyle.linear,
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.byType(Stack), findsWidgets);
      // Background, Optimal range (if true), Current level, Peak indicator (if higher)
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('renders meter style correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VolumeLevelIndicator(
              isActive: false,
              volumeLevel: 0.8,
              style: VolumeIndicatorStyle.meter,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Loud'), findsOneWidget);
      // Meter uses Column of segments
      expect(find.byType(Column), findsWidgets);
    });

    testWidgets('displays correct text for different volume levels', (tester) async {
      final levels = {
        0.05: 'Too Quiet',
        0.2: 'Quiet',
        0.5: 'Good',
        0.8: 'Loud',
        0.95: 'Too Loud',
      };

      for (final entry in levels.entries) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: VolumeLevelIndicator(
                isActive: false,
                volumeLevel: entry.key,
                style: VolumeIndicatorStyle.circular,
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text(entry.value), findsOneWidget);
      }
    });

    testWidgets('hides text when showText is false', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VolumeLevelIndicator(
              isActive: true,
              volumeLevel: 0.5,
              showText: false,
              style: VolumeIndicatorStyle.circular,
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.text('50%'), findsNothing);
      expect(find.text('Good'), findsNothing);
    });
  });

  group('CircularVolumePainter', () {
    test('shouldRepaint returns true when level changes', () {
      const painter1 = CircularVolumePainter(
        level: 0.5,
        color: Colors.green,
        thickness: 8.0,
        showOptimalRange: false,
      );
      const painter2 = CircularVolumePainter(
        level: 0.6,
        color: Colors.green,
        thickness: 8.0,
        showOptimalRange: false,
      );
      expect(painter1.shouldRepaint(painter2), isTrue);
    });
  });
}
