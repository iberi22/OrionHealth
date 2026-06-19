import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/meditation/presentation/widgets/meditation_timer.dart';

void main() {
  testWidgets('MeditationTimer formats duration correctly', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MeditationTimer(elapsedSeconds: 65),
        ),
      ),
    );

    expect(find.text('01:05'), findsOneWidget);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MeditationTimer(elapsedSeconds: 3600),
        ),
      ),
    );

    expect(find.text('60:00'), findsOneWidget);
  });
}
