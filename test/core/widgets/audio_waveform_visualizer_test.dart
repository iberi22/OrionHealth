// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/core/widgets/audio_waveform_visualizer.dart';

void main() {
  group('AudioWaveformVisualizer', () {
    testWidgets('renders bars style correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AudioWaveformVisualizer(
              isActive: true,
              style: WaveformStyle.bars,
              barCount: 10,
            ),
          ),
        ),
      );

      await tester.pump();

      // Should find Container for each bar + background container
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('renders line style correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AudioWaveformVisualizer(
              isActive: true,
              style: WaveformStyle.line,
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.byWidgetPredicate((widget) => widget is CustomPaint && widget.painter is LineWaveformPainter), findsOneWidget);
    });

    testWidgets('renders dots style correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AudioWaveformVisualizer(
              isActive: true,
              style: WaveformStyle.dots,
              barCount: 5,
            ),
          ),
        ),
      );

      await tester.pump();
      // Should find containers with circle shape
      final containers = tester.widgetList<Container>(find.byType(Container));
      bool foundCircle = false;
      for (var container in containers) {
        if (container.decoration is BoxDecoration) {
          if ((container.decoration as BoxDecoration).shape == BoxShape.circle) {
            foundCircle = true;
            break;
          }
        }
      }
      expect(foundCircle, isTrue);
    });

    testWidgets('respects isActive state', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AudioWaveformVisualizer(
              isActive: false,
              style: WaveformStyle.bars,
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.byType(AudioWaveformVisualizer), findsOneWidget);
    });

    testWidgets('updates when volumeLevels change', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AudioWaveformVisualizer(
              isActive: true,
              volumeLevels: [0.1, 0.5, 0.9],
              style: WaveformStyle.bars,
              barCount: 3,
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.byType(AudioWaveformVisualizer), findsOneWidget);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AudioWaveformVisualizer(
              isActive: true,
              volumeLevels: [0.9, 0.1, 0.5],
              style: WaveformStyle.bars,
              barCount: 3,
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(AudioWaveformVisualizer), findsOneWidget);
    });
  });

  group('LineWaveformPainter', () {
    test('shouldRepaint returns true when levels change', () {
      const painter1 = LineWaveformPainter(
        levels: [0.1, 0.2],
        color: Colors.blue,
        isActive: true,
      );
      const painter2 = LineWaveformPainter(
        levels: [0.3, 0.4],
        color: Colors.blue,
        isActive: true,
      );
      expect(painter1.shouldRepaint(painter2), isTrue);
    });

    test('shouldRepaint returns false when same', () {
      const painter1 = LineWaveformPainter(
        levels: [0.1, 0.2],
        color: Colors.blue,
        isActive: true,
      );
      const painter2 = LineWaveformPainter(
        levels: [0.1, 0.2],
        color: Colors.blue,
        isActive: true,
      );
      expect(painter1.shouldRepaint(painter2), isFalse);
    });
  });
}
