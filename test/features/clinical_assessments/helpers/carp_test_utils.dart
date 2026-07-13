import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:carp_themes_package/carp_themes_package.dart';

/// Shared CarpColors extension for clinical_assessments widget tests.
///
/// RPUITask from research_package requires CarpColors in ThemeData.extensions
/// or it crashes with: Null check operator used on a null value
/// at task.dart:324: Theme.of(context).extension<CarpColors>()!.backgroundGray
const carpColors = CarpColors(
  primary: Color(0xff006398),
  warningColor: Colors.orange,
  backgroundGray: Color(0xfff2f2f7),
  tabBarBackground: Color(0xffe3e3e4),
  white: Color(0xffFFFFFF),
  grey50: Color(0xffFCFCFF),
  grey100: Color(0xffF2F2F7),
  grey200: Color(0xffE5E5EA),
  grey300: Color(0xffD1D1D6),
  grey400: Color(0xffBABABA),
  grey500: Color(0xff9B9B9B),
  grey600: Color(0xff848484),
  grey700: Color(0xff3A3A3C),
  grey800: Color(0xff2C2C2E),
  grey900: Color(0xff1C1C1E),
  grey950: Color(0xff0E0E0E),
);

/// Creates a CupertinoApp with CarpColors theme extension for widget testing.
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
        data: ThemeData.light().copyWith(
          extensions: const [carpColors],
        ),
        child: child!,
      );
    },
    home: home,
  );
}
