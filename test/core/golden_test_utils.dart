import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Golden test utility helpers for OrionHealth golden tests.
/// Provides consistent wrappers and test lifecycle management.

/// Wraps a widget in MaterialApp + Scaffold for golden testing.
Widget wrapWithMaterial(Widget child, {String title = 'Test'}) {
  return MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );
}

/// Sets up common golden test configuration (device pixel ratio, etc.).
void setupGoldenTest(WidgetTester tester) {
  // No-op: Flutter golden tests don't need explicit setup beyond pump
}

/// Resets golden test state between test cases.
void resetGoldenTest(WidgetTester tester) {
  // No-op: cleanup is handled by test framework
}

/// Generates a golden test file name from the test description.
String goldenFileName(String testName) {
  return testName
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');
}
