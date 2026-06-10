import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class VideoRecorder {
  static Future<void> recordStep(
    WidgetTester tester,
    String flow,
    String stepName,
  ) async {
    await tester.pumpAndSettle();

    // Use matchesGoldenFile to capture the screenshot.
    // In integration tests, this will save to the specified path relative to the test file.
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('../screenshots/$flow/$stepName.png'),
    );

    print('Recorded step: $flow / $stepName');
  }
}
