import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/dashboard/presentation/widgets/activity_tile.dart';
import '../../../../core/golden_test_utils.dart';

void main() {
  group('ActivityTile Golden Tests', () {
    testWidgets('ActivityTile Single', (tester) async {
      setupGoldenTest(tester);

      await tester.pumpWidget(
        wrapWithMaterial(
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: ActivityTile(
                title: 'Heart rate check',
                time: 'Hace 5 minutos',
                icon: Icons.monitor_heart,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(ActivityTile),
        matchesGoldenFile("goldens/activity_tile_single.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('Activity List', (tester) async {
      setupGoldenTest(tester);

      await tester.pumpWidget(
        wrapWithMaterial(
          ListView(
            padding: const EdgeInsets.all(16.0),
            children: const [
              ActivityTile(
                title: 'Heart rate check',
                time: 'Hace 5 minutos',
                icon: Icons.monitor_heart,
              ),
              SizedBox(height: 12),
              ActivityTile(
                title: 'Vitamin D taken',
                time: 'Hace 2 horas',
                icon: Icons.done,
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(ListView),
        matchesGoldenFile("goldens/activity_list.png"),
      );
      resetGoldenTest(tester);
    });
  });
}
