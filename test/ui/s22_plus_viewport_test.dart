import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/core/widgets/swal_responsive.dart';

/// Galaxy S22+ viewport test suite.
/// Verifies that widgets render correctly on the target device dimensions.
void main() {
  // S22+ specs
  const Size s22Physical = Size(1080, 2340);
  const double s22Dpr = 3.0;
  const Size s22Logical = Size(360, 780);

  Future<void> setS22Viewport(WidgetTester tester) async {
    tester.view.physicalSize = s22Physical;
    tester.view.devicePixelRatio = s22Dpr;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  group('S22+ viewport rendering', () {
    testWidgets('default font size 14 fits in 360px width', (tester) async {
      await setS22Viewport(tester);
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text(
              'Sample text',
              style: TextStyle(fontSize: SWALFonts.body),
            ),
          ),
        ),
      ));
      final textWidget = tester.widget<Text>(find.text('Sample text'));
      expect(textWidget.style!.fontSize, SWALFonts.body);
      expect(textWidget.style!.fontSize, greaterThanOrEqualTo(14));
    });

    testWidgets('text scales down with SWALResponsive on S22+',
        (tester) async {
      await setS22Viewport(tester);
      const r = SWALResponsive<double>(
        compact: 14,
        medium: 18,
        expanded: 24,
      );
      // 360 logical width is compact
      expect(r.valueFor(360), 14);
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text(
              'Body',
              style: TextStyle(fontSize: r.valueFor(360)),
            ),
          ),
        ),
      ));
      expect(find.text('Body'), findsOneWidget);
    });

    testWidgets('long text wraps within S22+ width', (tester) async {
      await setS22Viewport(tester);
      const longText =
          'This is a long sentence that should wrap properly on a Galaxy S22+ '
          'screen with logical width 360 pixels, ensuring no horizontal overflow.';
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              longText,
              style: TextStyle(fontSize: SWALFonts.body),
            ),
          ),
        ),
      ));
      // No horizontal overflow
      expect(tester.takeException(), isNull);
    });

    testWidgets('48dp touch target respects Material guideline',
        (tester) async {
      await setS22Viewport(tester);
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: SWALSizes.touchTarget,
              height: SWALSizes.touchTarget,
              child: ElevatedButton(
                onPressed: () {},
                child: const Icon(Icons.add),
              ),
            ),
          ),
        ),
      ));
      final btn = tester.getSize(find.byType(ElevatedButton));
      expect(btn.width, 48);
      expect(btn.height, 48);
    });
  });

  group('S22+ screen size assertions', () {
    testWidgets('logical dimensions are 360x780', (tester) async {
      await setS22Viewport(tester);
      Size? captured;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(builder: (context) {
            captured = MediaQuery.sizeOf(context);
            return const SizedBox.shrink();
          }),
        ),
      ));
      expect(captured, s22Logical);
    });
  });
}
