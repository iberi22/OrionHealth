import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/medical_research/presentation/pages/scraper_config_page.dart';
import 'package:orionhealth_health/features/medical_research/presentation/pages/standards_viewer_page.dart';
import 'package:orionhealth_health/core/theme/cyber_theme.dart';

void main() {
  group('Medical Research Extra Pages Golden Tests', () {
    testWidgets('ScraperConfigPage Golden Test', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: ScraperConfigPage(),
        ),
      );

      await tester.pumpAndSettle();

      await expectLater(
        find.byType(ScraperConfigPage),
        matchesGoldenFile('goldens/scraper_config_page.png'),
      );

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    });

    testWidgets('StandardsViewerPage Golden Test', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: StandardsViewerPage(),
        ),
      );

      await tester.pumpAndSettle();

      await expectLater(
        find.byType(StandardsViewerPage),
        matchesGoldenFile('goldens/standards_viewer_page.png'),
      );

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    });
  });
}
