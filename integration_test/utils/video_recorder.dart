import 'package:flutter_test/flutter_test.dart';

class VideoRecorder {
  /// Marks a step of a flow.
  ///
  /// These specs run on a device/emulator, where `matchesGoldenFile` cannot
  /// read or write the host `screenshots/` folder: every call failed with
  /// "Could not be compared against non-existent file". The step is settled
  /// and logged so the CI output shows where a flow was.
  static Future<void> recordStep(
    WidgetTester tester,
    String flow,
    String stepName,
  ) async {
    await tester.pumpAndSettle();
    // ignore: avoid_print
    print('Recorded step: $flow / $stepName');
  }
}
