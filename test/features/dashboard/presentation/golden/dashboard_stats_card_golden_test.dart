// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:orionhealth_health/features/dashboard/presentation/widgets/dashboard_stats_card.dart';
import '../../../../../core/golden_test_utils.dart';

void main() {
  group('DashboardStatsCard Golden Tests', () {
    testWidgets('DashboardStatsCard matches golden with all stats', (tester) async {
      setupGoldenTest(tester, size: const Size(360, 200));

      final now = DateTime(2023, 10, 27, 10, 30);
      const stats = DashboardStats(
        totalMedications: 5,
        reportsCount: 3,
        lastVitalCheck: null,
      );

      await tester.pumpWidget(
        wrapWithMaterial(
          Scaffold(
            body: DashboardStatsCard(stats: stats),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(DashboardStatsCard),
        matchesGoldenFile('goldens/dashboard_stats_card_all_stats.png'),
      );

      resetGoldenTest(tester);
    });

    testWidgets('DashboardStatsCard matches golden with last vital check date',
        (tester) async {
      setupGoldenTest(tester, size: const Size(360, 200));

      final now = DateTime(2023, 10, 27, 10, 30);
      final stats = DashboardStats(
        totalMedications: 8,
        reportsCount: 12,
        lastVitalCheck: now,
      );

      await tester.pumpWidget(
        wrapWithMaterial(
          Scaffold(
            body: DashboardStatsCard(stats: stats),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(DashboardStatsCard),
        matchesGoldenFile('goldens/dashboard_stats_card_with_date.png'),
      );

      resetGoldenTest(tester);
    });

    testWidgets('DashboardStatsCard matches golden with zero values', (tester) async {
      setupGoldenTest(tester, size: const Size(360, 200));

      const stats = DashboardStats(
        totalMedications: 0,
        reportsCount: 0,
        lastVitalCheck: null,
      );

      await tester.pumpWidget(
        wrapWithMaterial(
          Scaffold(
            body: DashboardStatsCard(stats: stats),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(DashboardStatsCard),
        matchesGoldenFile('goldens/dashboard_stats_card_zero.png'),
      );

      resetGoldenTest(tester);
    });
  });
}
