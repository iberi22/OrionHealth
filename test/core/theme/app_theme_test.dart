import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/core/theme/app_theme.dart';
import 'package:orionhealth_health/core/theme/app_colors.dart';

void main() {
  group('AppTheme', () {
    test('darkTheme should have correct color scheme', () {
      final theme = AppTheme.darkTheme;

      expect(theme.brightness, Brightness.dark);
      expect(theme.colorScheme.primary, AppColors.primary);
      expect(theme.colorScheme.secondary, AppColors.secondary);
      expect(theme.colorScheme.surface, AppColors.surface);
      expect(theme.colorScheme.error, AppColors.error);
      expect(theme.scaffoldBackgroundColor, AppColors.background);
    });

    test('darkTheme should have correct card theme', () {
      final theme = AppTheme.darkTheme;

      expect(theme.cardTheme.color, AppColors.surface);
      expect(theme.cardTheme.elevation, 0);
      expect(theme.cardTheme.shape, isA<RoundedRectangleBorder>());
      final shape = theme.cardTheme.shape as RoundedRectangleBorder;
      expect(shape.borderRadius, BorderRadius.circular(16.0));
    });

    test('darkTheme should have correct elevated button theme', () {
      final theme = AppTheme.darkTheme;
      final style = theme.elevatedButtonTheme.style;

      expect(style?.backgroundColor?.resolve({}), AppColors.primary);
      expect(style?.foregroundColor?.resolve({}), AppColors.background);
    });

    test('darkTheme should have correct input decoration theme', () {
      final theme = AppTheme.darkTheme;
      final inputTheme = theme.inputDecorationTheme;

      expect(inputTheme.filled, isTrue);
      expect(inputTheme.fillColor, AppColors.surface);
      expect(inputTheme.labelStyle?.color, AppColors.textSecondary);
    });
  });
}
