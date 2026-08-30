/// SWAL Responsive Helper — S22+ first design
///
/// Galaxy S22+ specs:
/// - Resolution: 1080x2340
/// - Logical: 360x780 (devicePixelRatio 3.0)
/// - Density: ~425 DPI
///
/// Design system based on this reference device:
/// - textScaleFactor: 1.0 (no system scaling for predictable UI)
/// - safeArea: respect system insets (status bar, navigation bar)
/// - breakpoint compact: width < 600px
/// - breakpoint medium: 600px <= width < 1024px
/// - breakpoint expanded: width >= 1024px
library;

import 'package:flutter/material.dart';

/// Breakpoint thresholds (logical pixels).
class SWALBreakpoints {
  static const double compact = 600;
  static const double medium = 1024;

  static bool isCompact(double width) => width < compact;
  static bool isMedium(double width) => width >= compact && width < medium;
  static bool isExpanded(double width) => width >= medium;
}

/// Responsive values helper.
/// Provides different values per breakpoint for the same property.
class SWALResponsive<T> {
  final T compact;
  final T? medium;
  final T? expanded;

  const SWALResponsive({
    required this.compact,
    this.medium,
    this.expanded,
  });

  /// Pick the value for the current screen width.
  T valueFor(double width) {
    if (SWALBreakpoints.isExpanded(width) && expanded != null) {
      return expanded!;
    }
    if (SWALBreakpoints.isMedium(width) && medium != null) {
      return medium!;
    }
    return compact;
  }

  /// Convenience for font sizes.
  static SWALResponsive<double> font({
    required double compact,
    double? medium,
    double? expanded,
  }) =>
      SWALResponsive<double>(
        compact: compact,
        medium: medium,
        expanded: expanded,
      );

  /// Convenience for spacing/padding.
  static SWALResponsive<double> spacing({
    required double compact,
    double? medium,
    double? expanded,
  }) =>
      SWALResponsive<double>(
        compact: compact,
        medium: medium,
        expanded: expanded,
      );
}

/// Predefined S22+ tuned font sizes (no scaling applied).
class SWALFonts {
  /// Captions / timestamps (rarely used, only for badges)
  static const double caption = 12;

  /// Body text (minimum for any readable text)
  static const double body = 14;

  /// Body text emphasized
  static const double bodyLarge = 16;

  /// Subheadings / card titles
  static const double subtitle = 18;

  /// Section headers
  static const double title = 20;

  /// Page titles
  static const double headline = 24;

  /// Big numbers / hero text
  static const double display = 32;
}

/// Predefined spacing tokens for S22+.
class SWALSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

/// Predefined touch targets (Material Design recommends 48dp minimum).
class SWALSizes {
  /// Standard touch target (Material guideline: 48dp)
  static const double touchTarget = 48;

  /// Small icon button
  static const double iconButton = 40;

  /// Large CTA button
  static const double cta = 56;

  /// Avatar small
  static const double avatarSm = 32;

  /// Avatar large
  static const double avatarLg = 64;
}

/// Builder for adaptive content based on screen width.
class SWALAdaptiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext, SWALBreakpointInfo) builder;

  const SWALAdaptiveBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final info = SWALBreakpointInfo(
          width: width,
          isCompact: SWALBreakpoints.isCompact(width),
          isMedium: SWALBreakpoints.isMedium(width),
          isExpanded: SWALBreakpoints.isExpanded(width),
        );
        return builder(context, info);
      },
    );
  }
}

/// Current breakpoint information.
class SWALBreakpointInfo {
  final double width;
  final bool isCompact;
  final bool isMedium;
  final bool isExpanded;

  const SWALBreakpointInfo({
    required this.width,
    required this.isCompact,
    required this.isMedium,
    required this.isExpanded,
  });
}

/// Extension on BuildContext for quick access to responsive utilities.
extension SWALResponsiveContext on BuildContext {
  /// Get the current screen width.
  double get screenWidth => MediaQuery.sizeOf(this).width;

  /// Get the current screen height.
  double get screenHeight => MediaQuery.sizeOf(this).height;

  /// True if running on a phone-sized device (S22+ is compact).
  bool get isCompact => SWALBreakpoints.isCompact(screenWidth);

  /// Get device pixel ratio (S22+ is 3.0).
  double get devicePixelRatio => MediaQuery.devicePixelRatioOf(this);

  /// Safe area padding (notch, status bar, gesture bar).
  EdgeInsets get safeAreaPadding => MediaQuery.paddingOf(this);
}
