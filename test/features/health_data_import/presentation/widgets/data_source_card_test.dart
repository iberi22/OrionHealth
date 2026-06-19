import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/health_data_import/application/health_import_state.dart';
import 'package:orionhealth_health/features/health_data_import/presentation/widgets/data_source_card.dart';
import 'package:orionhealth_health/core/widgets/glassmorphic_card.dart';

void main() {
  Widget createWidgetUnderTest({
    required HealthDataSource source,
    required bool isAvailable,
    DateTime? lastSync,
    VoidCallback? onImport,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: DataSourceCard(
          source: source,
          isAvailable: isAvailable,
          lastSync: lastSync,
          onImport: onImport,
        ),
      ),
    );
  }

  group('DataSourceCard', () {
    testWidgets('renders correctly for available source', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        source: HealthDataSource.googleFit,
        isAvailable: true,
      ));

      expect(find.textContaining('Google Fit'), findsOneWidget);
      expect(find.text('Available'), findsOneWidget);
      expect(find.text('Never synced'), findsOneWidget);
      expect(find.byIcon(Icons.fitness_center), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('renders correctly for unavailable source', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        source: HealthDataSource.appleHealth,
        isAvailable: false,
      ));

      expect(find.text('Apple Health'), findsOneWidget);
      expect(find.text('Not available'), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });

    testWidgets('shows correct last sync text', (tester) async {
      final now = DateTime.now();
      final tenMinutesAgo = now.subtract(const Duration(minutes: 10));

      await tester.pumpWidget(createWidgetUnderTest(
        source: HealthDataSource.googleFit,
        isAvailable: true,
        lastSync: tenMinutesAgo,
      ));

      expect(find.text('Last sync: 10m ago'), findsOneWidget);
    });

    testWidgets('calls onImport when button is pressed', (tester) async {
      bool called = false;
      await tester.pumpWidget(createWidgetUnderTest(
        source: HealthDataSource.googleFit,
        isAvailable: true,
        onImport: () => called = true,
      ));

      await tester.tap(find.byType(ElevatedButton));
      expect(called, true);
    });

    testWidgets('button is disabled when not available', (tester) async {
      bool called = false;
      await tester.pumpWidget(createWidgetUnderTest(
        source: HealthDataSource.googleFit,
        isAvailable: false,
        onImport: () => called = true,
      ));

      await tester.tap(find.byType(ElevatedButton));
      expect(called, false);
    });
  });
}
