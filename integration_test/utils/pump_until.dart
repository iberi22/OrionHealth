import 'package:flutter_test/flutter_test.dart';

/// Pumps real time until [finder] matches.
///
/// Isar/IO futures are not frame-bound, so `pumpAndSettle` can return before a
/// cubit has loaded its data; poll for the expected widget instead.
Future<void> pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 20),
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    if (finder.evaluate().isNotEmpty) break;
    await tester.pump(const Duration(milliseconds: 200));
  }
  await tester.pumpAndSettle();
}
