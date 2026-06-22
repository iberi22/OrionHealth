import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/core/theme/app_colors.dart';

void main() {
  group('AppColors', () {
    test('verify brand colors', () {
      expect(AppColors.primary, const Color(0xFF00FF85));
      expect(AppColors.secondary, const Color(0xFF00E0FF));
    });

    test('verify background and surface colors', () {
      expect(AppColors.background, const Color(0xFF0A0A0A));
      expect(AppColors.surface, const Color(0xFF1A1A1A));
      expect(AppColors.surfaceVariant, const Color(0xFF2A2A2A));
    });

    test('verify text colors', () {
      expect(AppColors.textPrimary, const Color(0xFFE0E0E0));
      expect(AppColors.textSecondary, const Color(0xFF9E9E9E));
    });

    test('verify semantic colors', () {
      expect(AppColors.error, Colors.redAccent);
      expect(AppColors.warning, Colors.orange);
      expect(AppColors.success, AppColors.primary);
    });

    test('verify utility colors', () {
      expect(AppColors.glassBorder, const Color(0x1AFFFFFF));
      expect(AppColors.glassBackground, const Color(0x0DFFFFFF));
    });
  });
}
