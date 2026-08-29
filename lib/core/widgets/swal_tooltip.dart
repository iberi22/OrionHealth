// SPDX-License-Identifier: AGPL-3.0-only
// Copyright (C) 2025 OrionHealth Contributors

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Reusable SWAL Tooltip wrapper that centralizes theme styling, wait/show duration,
/// and accessibility semantics for tooltips across the application.
class SWALTooltip extends StatelessWidget {
  final String message;
  final Widget child;

  const SWALTooltip({super.key, required this.message, required this.child});

  @override
  Widget build(BuildContext context) {
    if (message.isEmpty) return child;

    return Tooltip(
      message: message,
      waitDuration: const Duration(milliseconds: 500),
      showDuration: const Duration(seconds: 2),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.glassBorder),
      ),
      textStyle: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
      child: child,
    );
  }
}
