// SPDX-License-Identifier: AGPL-3.0-only
// Copyright (C) 2025 OrionHealth Contributors

import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_theme.dart';

/// CyberTheme bridge for newer page templates.
/// Integrates with existing AppColors and AppTheme.
class CyberTheme {
  static const Color primary = AppColors.primary;
  static const Color secondary = AppColors.secondary;
  static const Color backgroundDark = AppColors.background;
  static const Color surfaceDark = AppColors.surface;
  static const Color textDark = AppColors.textPrimary;

  static ThemeData get darkTheme => AppTheme.darkTheme;
}
