import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:orionhealth_health/features/dashboard/presentation/widgets/dashboard_stats_card.dart';

void main() {
  group('DashboardStatsCard', () {
    testWidgets('renders stats correctly with valid data', (WidgetTester tester) async {
      final now = DateTime(2023, 10, 27);
      final stats = DashboardStats(
        totalMedications: 5,
        reportsCount: 3,
        lastVitalCheck: now,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DashboardStatsCard(stats: stats),
          ),
        ),
      );

      expect(find.text('RESUMEN DE SALUD'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('27/10'), findsOneWidget);

      expect(find.byIcon(Icons.medication), findsOneWidget);
      expect(find.byIcon(Icons.description), findsOneWidget);
      expect(find.byIcon(Icons.monitor_heart), findsOneWidget);
    });

    testWidgets('handles null and zero values correctly', (WidgetTester tester) async {
      const stats = DashboardStats(
        totalMedications: 0,
        reportsCount: 0,
        lastVitalCheck: null,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DashboardStatsCard(stats: stats),
          ),
        ),
      );

      expect(find.text('0'), findsNWidgets(2));
      expect(find.text('N/A'), findsOneWidget);
    });

    testWidgets('displays correct labels', (WidgetTester tester) async {
      const stats = DashboardStats(
        totalMedications: 1,
        reportsCount: 1,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DashboardStatsCard(stats: stats),
          ),
        ),
      );

      expect(find.text('Medicamentos'), findsOneWidget);
      expect(find.text('Informes'), findsOneWidget);
      expect(find.text('Último Control'), findsOneWidget);
    });
  });
}
