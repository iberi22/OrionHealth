import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/core/theme/cyber_theme.dart';
import 'package:orionhealth_health/core/theme/app_colors.dart';

void main() {
  group('CyberTheme', () {
    test('verify constants match AppColors', () {
      expect(CyberTheme.primary, AppColors.primary);
      expect(CyberTheme.secondary, AppColors.secondary);
      expect(CyberTheme.backgroundDark, AppColors.background);
      expect(CyberTheme.surfaceDark, AppColors.surface);
      expect(CyberTheme.textDark, AppColors.textPrimary);
    });

    test('darkTheme bridge returns valid ThemeData', () {
      final theme = CyberTheme.darkTheme;
      expect(theme, isA<ThemeData>());
      expect(theme.brightness, Brightness.dark);
      expect(theme.colorScheme.primary, AppColors.primary);
    });
  });
}
