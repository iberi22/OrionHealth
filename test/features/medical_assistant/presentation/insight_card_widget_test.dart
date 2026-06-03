import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/medical_assistant/domain/entities/medical_insight.dart';
import 'package:orionhealth_health/features/medical_assistant/presentation/widgets/insight_card.dart';

void main() {
  group('InsightCard Widget Tests', () {
    final testInsight = MedicalInsight(
      id: 'insight-1',
      title: 'Elevated Blood Pressure',
      description: 'Your systolic blood pressure is higher than normal (140 mmHg).',
      severity: InsightSeverity.warning,
      category: InsightCategory.vitalSignAnalysis,
      generatedAt: DateTime.now(),
      recommendations: ['Monitor daily', 'Reduce salt intake'],
      guidelineReference: 'AHA 2017 Guidelines',
    );

    testWidgets('renders title and description', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InsightCard(insight: testInsight),
          ),
        ),
      );

      expect(find.text('Elevated Blood Pressure'), findsOneWidget);
      expect(find.text('Your systolic blood pressure is higher than normal (140 mmHg).'), findsOneWidget);
    });

    testWidgets('renders category chip with correct label', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InsightCard(insight: testInsight),
          ),
        ),
      );

      // _categoryLabel(InsightCategory.vitalSignAnalysis) returns 'Vitals'
      expect(find.text('Vitals'), findsOneWidget);
    });

    testWidgets('renders severity icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InsightCard(insight: testInsight),
          ),
        ),
      );

      // Warning severity uses Icons.info (according to the code I read earlier)
      expect(find.byIcon(Icons.info), findsOneWidget);
    });

    testWidgets('renders recommendations (first 2)', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InsightCard(insight: testInsight),
          ),
        ),
      );

      expect(find.text('Monitor daily'), findsOneWidget);
      expect(find.text('Reduce salt intake'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline), findsNWidgets(2));
    });

    testWidgets('renders guideline reference', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InsightCard(insight: testInsight),
          ),
        ),
      );

      expect(find.text('Ref: AHA 2017 Guidelines'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (WidgetTester tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InsightCard(
              insight: testInsight,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(InsightCard));
      expect(tapped, isTrue);
    });

    testWidgets('renders critical severity icon correctly', (WidgetTester tester) async {
      final criticalInsight = testInsight.copyWith(severity: InsightSeverity.critical);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InsightCard(insight: criticalInsight),
          ),
        ),
      );

      expect(find.byIcon(Icons.error), findsOneWidget);
    });
  });
}
