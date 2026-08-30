/// SWAL Animations — Lightweight motion library
///
/// Optimized for mid-range devices (Galaxy S22+ = Snapdragon 8 Gen 1).
/// Uses `AnimatedSwitcher`, `Hero`, and `TweenAnimationBuilder` for
/// GPU-accelerated, lightweight animations. Avoids heavy custom painters
/// and CustomPainter to reduce jank.
library;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Standard SWAL animation durations (in milliseconds).
class SWALDurations {
  /// Fast micro-interactions (ripples, hover)
  static const Duration fast = Duration(milliseconds: 150);

  /// Standard transitions (page changes, cards)
  static const Duration normal = Duration(milliseconds: 250);

  /// Slow emphasis (hero, splash, dialog)
  static const Duration slow = Duration(milliseconds: 400);

  /// Page transitions
  static const Duration pageTransition = Duration(milliseconds: 300);
}

/// Standard SWAL animation curves.
class SWALCurves {
  /// Material standard easing.
  static const Curve standard = Curves.easeInOutCubic;

  /// Decelerate (entries, page transitions)
  static const Curve decelerate = Curves.easeOutQuart;

  /// Accelerate (exits)
  static const Curve accelerate = Curves.easeInCubic;
}

/// Fade-in animation wrapper.
///
/// Lightweight: uses [AnimatedOpacity] which is GPU-accelerated.
class SWALFadeIn extends StatelessWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;

  const SWALFadeIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = SWALDurations.normal,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration + delay,
      curve: SWALCurves.decelerate,
      builder: (context, value, child) {
        return Opacity(opacity: value, child: child);
      },
      child: child,
    );
  }
}

/// Slide + fade entrance animation.
class SWALSlideIn extends StatelessWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final Offset from;

  const SWALSlideIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = SWALDurations.normal,
    this.from = const Offset(0, 0.1),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration + delay,
      curve: SWALCurves.decelerate,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(
              from.dx * (1 - value) * 100,
              from.dy * (1 - value) * 100,
            ),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

/// Scale-in entrance animation (for modals, popups).
class SWALScaleIn extends StatelessWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;

  const SWALScaleIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = SWALDurations.fast,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.9, end: 1.0),
      duration: duration + delay,
      curve: SWALCurves.standard,
      builder: (context, value, child) {
        return Opacity(
          opacity: value.clamp(0.0, 1.0),
          child: Transform.scale(scale: value, child: child),
        );
      },
      child: child,
    );
  }
}

/// Page transition theme tuned for S22+ (smoother than Material default).
PageTransitionsTheme get swalPageTransitionsTheme => const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: ZoomPageTransitionsBuilder(
          allowSnapshotting: false,
        ),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.linux: ZoomPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: ZoomPageTransitionsBuilder(),
      },
    );
