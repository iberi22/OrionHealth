import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Default surface of a `flutter test` view before a test customises it:
/// 800x600 logical at devicePixelRatio 3.0 = 2400x1800 physical pixels.
const Size _defaultPhysicalSurface = Size(2400, 1800);
const double _defaultDevicePixelRatio = 3.0;

/// Golden test utility helpers for OrionHealth golden tests.
/// Provides consistent wrappers and test lifecycle management.

/// Wraps a widget in MaterialApp + Scaffold for golden testing.
Widget wrapWithMaterial(Widget child, {String title = 'Test'}) {
  return MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );
}

/// Pins the golden surface to the phone size the committed masters were captured
/// with: [size] (default 360x640) physical pixels at devicePixelRatio 1.0.
///
/// Without this, tests render on the default 2400x1800 @ 3.0 surface and every
/// comparison fails with "image sizes do not match" (master 360x640, test
/// 2400x1800). A test that already pinned its own `physicalSize` /
/// `devicePixelRatio` keeps it.
void setupGoldenTest(WidgetTester tester, {Size size = const Size(360, 640)}) {
  if (tester.view.physicalSize == _defaultPhysicalSurface) {
    tester.view.physicalSize = size;
  }
  if (tester.view.devicePixelRatio == _defaultDevicePixelRatio) {
    tester.view.devicePixelRatio = 1.0;
  }
}

/// Resets golden test state between test cases.
void resetGoldenTest(WidgetTester tester) {
  tester.view.resetPhysicalSize();
  tester.view.resetDevicePixelRatio();
}

/// Generates a golden test file name from the test description.
String goldenFileName(String testName) {
  return testName
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');
}
