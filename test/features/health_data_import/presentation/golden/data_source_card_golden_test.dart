import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/health_data_import/domain/entities/health_data_source.dart';
import 'package:orionhealth_health/features/health_data_import/presentation/widgets/data_source_card.dart';
import '../../../../core/golden_test_utils.dart';

void main() {
  group('DataSourceCard Golden Tests', () {
    testWidgets('Google Fit - Available and recently synced', (WidgetTester tester) async {
      setupGoldenTest(tester);

      final lastSync = DateTime.now().subtract(const Duration(minutes: 30));

      await tester.pumpWidget(
        wrapWithMaterial(
          Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: DataSourceCard(
                  source: HealthDataSource.googleFit,
                  isAvailable: true,
                  lastSync: lastSync,
                  onImport: () {},
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(DataSourceCard),
        matchesGoldenFile("goldens/data_source_card_google_fit.png"),
      );

      resetGoldenTest(tester);
    });

    testWidgets('Apple Health - Not available and never synced', (WidgetTester tester) async {
      setupGoldenTest(tester);

      await tester.pumpWidget(
        wrapWithMaterial(
          const Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: DataSourceCard(
                  source: HealthDataSource.appleHealth,
                  isAvailable: false,
                  lastSync: null,
                  onImport: null,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(DataSourceCard),
        matchesGoldenFile("goldens/data_source_card_apple_health.png"),
      );

      resetGoldenTest(tester);
    });

    testWidgets('Samsung Health - Available and synced 2 days ago', (WidgetTester tester) async {
      setupGoldenTest(tester);

      final lastSync = DateTime.now().subtract(const Duration(days: 2));

      await tester.pumpWidget(
        wrapWithMaterial(
          Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: DataSourceCard(
                  source: HealthDataSource.samsungHealth,
                  isAvailable: true,
                  lastSync: lastSync,
                  onImport: () {},
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(DataSourceCard),
        matchesGoldenFile("goldens/data_source_card_samsung_health.png"),
      );

      resetGoldenTest(tester);
    });
  });
}
