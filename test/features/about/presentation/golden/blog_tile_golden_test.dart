import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/about/presentation/pages/about_page.dart';
import 'package:orionhealth_health/features/about/domain/entities/about_info.dart';
import '../../../../core/golden_test_utils.dart';

void main() {
  group('BlogTile Golden Test', () {
    testWidgets('BlogTile - Standard', (tester) async {
      setupGoldenTest(tester);

      const post = BlogPost(
        title: 'El futuro de la salud soberana',
        content: 'Los datos de salud pertenecen al paciente, no a las instituciones. En OrionHealth trabajamos para que esto sea una realidad diaria.',
        date: '10 Jun 2026',
        category: 'Noticias',
      );

      await tester.pumpWidget(
        wrapWithMaterial(
          const Scaffold(
            body: Padding(
              padding: EdgeInsets.all(16.0),
              child: BlogTile(post: post),
            ),
          ),
        ),
      );
      await tester.pump();

      await expectLater(
        find.byType(BlogTile),
        matchesGoldenFile("goldens/blog_tile.png"),
      );
      resetGoldenTest(tester);
    });
  });
}
