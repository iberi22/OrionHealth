import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/reports/domain/entities/report.dart';
import 'package:orionhealth_health/features/reports/presentation/widgets/report_card.dart';

void main() {
  group('ReportCard', () {
    final tReport = Report(
      title: 'Test Report',
      generatedAt: DateTime(2023, 1, 1, 10, 30),
      status: ReportStatus.finalized,
    );

    testWidgets('displays title, date and status correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReportCard(
              report: tReport,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Test Report'), findsOneWidget);
      expect(find.text('01 Jan, 10:30 AM'), findsOneWidget);
      expect(find.text('FINALIZADO'), findsOneWidget);
    });

    testWidgets('calls onTap when pressed', (WidgetTester tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReportCard(
              report: tReport,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ReportCard));
      expect(tapped, isTrue);
    });

    testWidgets('displays correct icon and badge for urgent status', (WidgetTester tester) async {
      final urgentReport = Report(
        title: 'Urgent Report',
        status: ReportStatus.urgent,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReportCard(
              report: urgentReport,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
      expect(find.text('URGENTE'), findsOneWidget);
    });

    testWidgets('displays correct icon and badge for pending status', (WidgetTester tester) async {
      final pendingReport = Report(
        title: 'Pending Report',
        status: ReportStatus.pending,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReportCard(
              report: pendingReport,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.hourglass_empty_rounded), findsOneWidget);
      expect(find.text('PENDIENTE'), findsOneWidget);
    });

    testWidgets('displays "Fecha desconocida" when generatedAt is null', (WidgetTester tester) async {
      final noDateReport = Report(
        title: 'No Date Report',
        generatedAt: null,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReportCard(
              report: noDateReport,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Fecha desconocida'), findsOneWidget);
    });

    testWidgets('displays "Sin título" when title is null', (WidgetTester tester) async {
      final noTitleReport = Report(
        title: null,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReportCard(
              report: noTitleReport,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Sin título'), findsOneWidget);
    });
  });
}
