import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/health_sharing/presentation/pages/share_page.dart';

void main() {
  testWidgets('SharePage golden test', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: SharePage()),
    );
    await expectLater(
      find.byType(SharePage),
      matchesGoldenFile('goldens/share_page.png'),
    );
  });
}
