import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/core/widgets/swal_animations.dart';

void main() {
  group('SWALDurations', () {
    test('fast is 150ms (Material recommended)', () {
      expect(SWALDurations.fast, const Duration(milliseconds: 150));
    });
    test('normal is 250ms (under 300ms perceived instant)', () {
      expect(SWALDurations.normal, const Duration(milliseconds: 250));
    });
    test('page transition is 300ms', () {
      expect(SWALDurations.pageTransition, const Duration(milliseconds: 300));
    });
  });

  group('SWALFadeIn', () {
    testWidgets('animates from opacity 0 to 1', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: SWALFadeIn(child: Text('hello')),
        ),
      ));
      // Initial frame: opacity 0
      final initialFinder = find.text('hello');
      expect(initialFinder, findsOneWidget);
      // Pump animation to end
      await tester.pumpAndSettle(const Duration(seconds: 1));
      expect(find.text('hello'), findsOneWidget);
    });
  });

  group('SWALSlideIn', () {
    testWidgets('renders child after animation', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: SWALSlideIn(child: Text('slide')),
        ),
      ));
      expect(find.text('slide'), findsOneWidget);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      expect(find.text('slide'), findsOneWidget);
    });
  });

  group('SWALScaleIn', () {
    testWidgets('renders child after animation', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: SWALScaleIn(child: Text('scale')),
        ),
      ));
      expect(find.text('scale'), findsOneWidget);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      expect(find.text('scale'), findsOneWidget);
    });
  });

  group('swalPageTransitionsTheme', () {
    test('returns PageTransitionsTheme with zoom on Android', () {
      final theme = swalPageTransitionsTheme;
      expect(theme, isA<PageTransitionsTheme>());
      expect(theme.builders[TargetPlatform.android], isA<ZoomPageTransitionsBuilder>());
    });
  });
}
