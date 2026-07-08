import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/health_sharing/presentation/pages/receive_page.dart';

void main() {
  testWidgets('ReceivePage golden test', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: ReceivePage()),
    );
    await expectLater(
      find.byType(ReceivePage),
      matchesGoldenFile('goldens/receive_page.png'),
    );
  });
}
