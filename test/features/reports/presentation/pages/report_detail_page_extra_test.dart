import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/reports/domain/entities/report.dart';
import 'package:orionhealth_health/features/reports/presentation/pages/report_detail_page.dart';

void main() {
  group('ReportDetailPage Extra Tests', () {
    testWidgets('displays title and handles long content', (tester) async {
      final report = Report(
        title: 'Long Report',
        content: 'Line 1\n' * 100,
        status: ReportStatus.finalized,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ReportDetailPage(report: report),
        ),
      );

      expect(find.text('Long Report'), findsOneWidget);
      // Should be scrollable
      expect(find.byType(SingleChildScrollView), findsNothing); // It uses CustomScrollView
      expect(find.byType(CustomScrollView), findsOneWidget);
    });
  });
}
