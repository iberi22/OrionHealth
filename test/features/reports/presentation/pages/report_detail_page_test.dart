import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:orionhealth_health/features/reports/domain/entities/report.dart';
import 'package:orionhealth_health/features/reports/presentation/pages/report_detail_page.dart';

void main() {
  group('ReportDetailPage', () {
    final tReport = Report(
      title: 'Detailed Report',
      content: '# Summary\nThis is a test report content.',
      status: ReportStatus.finalized,
      generatedAt: DateTime(2023, 1, 1),
    );

    testWidgets('displays title and markdown content', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ReportDetailPage(report: tReport),
        ),
      );

      expect(find.text('Detailed Report'), findsOneWidget);
      expect(find.byType(Markdown), findsOneWidget);
      expect(find.text('Summary'), findsOneWidget);
      expect(find.text('This is a test report content.'), findsOneWidget);
    });

    testWidgets('wraps content in a RepaintBoundary', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ReportDetailPage(report: tReport),
        ),
      );

      // Verify that the body is a RepaintBoundary
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.body, isA<RepaintBoundary>());

      // Verify that there is a RepaintBoundary in the tree (could be multiple from MaterialApp/Navigator)
      expect(find.byType(RepaintBoundary), findsAtLeastNWidgets(1));
    });

    testWidgets('displays default title when title is null', (tester) async {
      final noTitleReport = Report(
        title: null,
        content: 'Content',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ReportDetailPage(report: noTitleReport),
        ),
      );

      expect(find.text('Detalle del Informe'), findsOneWidget);
    });

    testWidgets('handles null content gracefully', (tester) async {
      final noContentReport = Report(
        title: 'Title',
        content: null,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ReportDetailPage(report: noContentReport),
        ),
      );

      expect(find.byType(Markdown), findsOneWidget);
      final markdown = tester.widget<Markdown>(find.byType(Markdown));
      expect(markdown.data, '');
    });

    testWidgets('AppBar contains the correct title', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ReportDetailPage(report: tReport),
        ),
      );

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      final titleText = appBar.title as Text;
      expect(titleText.data, 'Detailed Report');
    });

    testWidgets('AppBar contains the default title when report title is null', (tester) async {
      final noTitleReport = Report(title: null);
      await tester.pumpWidget(
        MaterialApp(
          home: ReportDetailPage(report: noTitleReport),
        ),
      );

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      final titleText = appBar.title as Text;
      expect(titleText.data, 'Detalle del Informe');
    });
  });
}
