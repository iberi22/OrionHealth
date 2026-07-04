import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/dashboard/presentation/widgets/quick_action_card.dart';
import 'package:orionhealth_health/core/theme/cyber_theme.dart';
import '../../../../core/golden_test_utils.dart';

void main() {
  group('QuickActionCard Golden Tests', () {
    testWidgets('QuickActionCard Single', (tester) async {
      setupGoldenTest(tester);

      await tester.pumpWidget(
        wrapWithMaterial(
          Center(
            child: SizedBox(
              width: 150,
              height: 150,
              child: QuickActionCard(
                title: 'Test Action',
                icon: Icons.star,
                color: CyberTheme.primary,
                onTap: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(QuickActionCard),
        matchesGoldenFile("goldens/quick_action_card_single.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('QuickActionCard Grid', (tester) async {
      setupGoldenTest(tester);

      await tester.pumpWidget(
        wrapWithMaterial(
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                QuickActionCard(
                  title: 'AI Assistant',
                  icon: Icons.psychology,
                  color: CyberTheme.primary,
                  onTap: () {},
                ),
                QuickActionCard(
                  title: 'Salud',
                  icon: Icons.favorite,
                  color: Colors.redAccent,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(GridView),
        matchesGoldenFile("goldens/quick_actions_grid.png"),
      );
      resetGoldenTest(tester);
    });
  });
}
