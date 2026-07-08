import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/medical_research/presentation/widgets/interaction_checker_widget.dart';

void main() {
  testWidgets('InteractionCheckerWidget golden test', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: InteractionCheckerWidget())),
    );
    await expectLater(
      find.byType(InteractionCheckerWidget),
      matchesGoldenFile('goldens/interaction_checker_widget.png'),
    );
  });
}
