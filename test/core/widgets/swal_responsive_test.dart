import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/core/widgets/swal_responsive.dart';

void main() {
  group('SWALBreakpoints', () {
    test('isCompact returns true for phone-sized widths', () {
      expect(SWALBreakpoints.isCompact(360), true);  // S22+ logical width
      expect(SWALBreakpoints.isCompact(599), true);
      expect(SWALBreakpoints.isCompact(0), true);
    });

    test('isCompact returns false for tablet widths', () {
      expect(SWALBreakpoints.isCompact(600), false);
      expect(SWALBreakpoints.isCompact(800), false);
      expect(SWALBreakpoints.isCompact(1024), false);
    });

    test('isMedium returns true for tablet widths', () {
      expect(SWALBreakpoints.isMedium(600), true);
      expect(SWALBreakpoints.isMedium(800), true);
      expect(SWALBreakpoints.isMedium(1023), true);
    });

    test('isMedium returns false for phones and desktops', () {
      expect(SWALBreakpoints.isMedium(360), false);
      expect(SWALBreakpoints.isMedium(1024), false);
    });

    test('isExpanded returns true for desktop widths', () {
      expect(SWALBreakpoints.isExpanded(1024), true);
      expect(SWALBreakpoints.isExpanded(1920), true);
    });

    test('isExpanded returns false for phones and tablets', () {
      expect(SWALBreakpoints.isExpanded(360), false);
      expect(SWALBreakpoints.isExpanded(600), false);
      expect(SWALBreakpoints.isExpanded(1023), false);
    });
  });

  group('SWALResponsive', () {
    test('returns compact value for phone widths', () {
      const r = SWALResponsive<int>(compact: 1, medium: 2, expanded: 3);
      expect(r.valueFor(360), 1);
    });

    test('returns medium value for tablet widths', () {
      const r = SWALResponsive<int>(compact: 1, medium: 2, expanded: 3);
      expect(r.valueFor(800), 2);
    });

    test('returns expanded value for desktop widths', () {
      const r = SWALResponsive<int>(compact: 1, medium: 2, expanded: 3);
      expect(r.valueFor(1920), 3);
    });

    test('falls back to compact when medium/expanded null', () {
      const r = SWALResponsive<int>(compact: 1);
      expect(r.valueFor(360), 1);
      expect(r.valueFor(800), 1);
      expect(r.valueFor(1920), 1);
    });

    test('font factory works', () {
      final f = SWALResponsive.font(compact: 14, medium: 16);
      expect(f.valueFor(360), 14);
      expect(f.valueFor(800), 16);
    });

    test('spacing factory works', () {
      final s = SWALResponsive.spacing(compact: 16, expanded: 32);
      expect(s.valueFor(360), 16);
      expect(s.valueFor(1920), 32);
    });
  });

  group('SWALFonts (S22+ minimums)', () {
    test('body minimum is 14 (legible on S22+)', () {
      expect(SWALFonts.body, greaterThanOrEqualTo(14));
    });

    test('caption is 12 (allowed for badges only)', () {
      expect(SWALFonts.caption, 12);
    });

    test('all sizes form a clear scale', () {
      expect(SWALFonts.caption, lessThan(SWALFonts.body));
      expect(SWALFonts.body, lessThan(SWALFonts.bodyLarge));
      expect(SWALFonts.bodyLarge, lessThan(SWALFonts.subtitle));
      expect(SWALFonts.subtitle, lessThan(SWALFonts.title));
      expect(SWALFonts.title, lessThan(SWALFonts.headline));
      expect(SWALFonts.headline, lessThan(SWALFonts.display));
    });
  });

  group('SWALSizes (Material guidelines)', () {
    test('touchTarget is >= 48 (Material minimum)', () {
      expect(SWALSizes.touchTarget, greaterThanOrEqualTo(48));
    });
  });

  group('SWALAdaptiveBuilder', () {
    testWidgets('calls builder with compact info for phone', (tester) async {
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      SWALBreakpointInfo? captured;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SWALAdaptiveBuilder(
            builder: (context, info) {
              captured = info;
              return const SizedBox.shrink();
            },
          ),
        ),
      ));
      expect(captured, isNotNull);
      expect(captured!.isCompact, true);
    });
  });

  group('SWALResponsiveContext extension', () {
    testWidgets('exposes screenWidth, screenHeight, devicePixelRatio',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      BuildContext? ctx;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(builder: (context) {
            ctx = context;
            return const SizedBox.shrink();
          }),
        ),
      ));
      expect(ctx, isNotNull);
      // Logical size = physical / DPR
      expect(ctx!.screenWidth, 360);  // S22+ logical width
      expect(ctx!.screenHeight, 780);  // S22+ logical height
      expect(ctx!.devicePixelRatio, 3.0);
      expect(ctx!.isCompact, true);
    });
  });
}
