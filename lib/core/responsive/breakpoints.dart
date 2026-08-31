// SPDX-License-Identifier: AGPL-3.0-only
// @deprecated — Use lib/core/widgets/swal_responsive.dart (SWALBreakpoints) instead.
// This file is kept for ABI compatibility and will be removed in v0.11.
// See Wave 13: responsive consolidation.
// ignore_for_file: deprecated_member_use
library;

import '../widgets/swal_responsive.dart';

@Deprecated('Use SWALBreakpoints from swal_responsive.dart')
class Breakpoints {
  @Deprecated('Use SWALBreakpoints.compact')
  static const double mobile = SWALBreakpoints.compact;
  @Deprecated('Use SWALBreakpoints.medium')
  static const double tablet = SWALBreakpoints.medium;
  @Deprecated('Use 1440 directly or SWALBreakpoints.expanded check')
  static const double desktop = 1440;

  @Deprecated('Use SWALBreakpoints.isCompact')
  static bool isMobile(double width) => SWALBreakpoints.isCompact(width);
  @Deprecated('Use SWALBreakpoints.isMedium')
  static bool isTablet(double width) =>
      SWALBreakpoints.isMedium(width) || SWALBreakpoints.isExpanded(width) == false && width >= SWALBreakpoints.compact;
  @Deprecated('Use SWALBreakpoints.isExpanded')
  static bool isDesktop(double width) => SWALBreakpoints.isExpanded(width);
}
