import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Shared theme for the clinical_assessments widget tests.
///
/// Before research_package 2.4.0 the CARP consent/survey widgets read the page
/// background from the `CarpColors` theme extension and crashed when it was
/// missing. carp_themes_package 0.1.0 removed that extension (research_package
/// 2.4.x reads `Theme.of(context).scaffoldBackgroundColor` instead), so the
/// tests only need a plain light theme now.
///
/// Creates a CupertinoApp with that theme for widget testing.
///
/// Usage:
/// ```dart
/// await tester.pumpWidget(createCarpTestApp(ConsentScreen(repository: mockRepo)));
/// ```
Widget createCarpTestApp(Widget home) {
  return CupertinoApp(
    theme: const CupertinoThemeData().copyWith(
      primaryColor: CupertinoColors.activeBlue,
      brightness: Brightness.light,
    ),
    builder: (context, child) {
      return Theme(
        data: ThemeData.light(),
        child: child!,
      );
    },
    home: home,
  );
}
