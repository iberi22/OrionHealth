import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/about/presentation/widgets/mission_section.dart';

void main() {
  group('MissionSection Widget', () {
    const tMission = 'Hacer la salud accesible para todos los colombianos.';
    final tValues = [
      'Transparencia y confianza',
      'Innovación constante',
      'Acceso universal a la salud',
    ];
    final tActivities = [
      'Gestión de citas médicas',
      'Recordatorios de medicamentos',
      'Integración con EPS',
    ];

    testWidgets('displays mission statement', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MissionSection(
              missionStatement: tMission,
              values: tValues,
              activities: tActivities,
            ),
          ),
        ),
      );

      expect(find.text('NUESTRA MISIÓN'), findsOneWidget);
      expect(find.text(tMission), findsOneWidget);
    });

    testWidgets('displays all values', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MissionSection(
              missionStatement: tMission,
              values: tValues,
              activities: tActivities,
            ),
          ),
        ),
      );

      expect(find.text('Creemos que:'), findsOneWidget);
      for (final value in tValues) {
        expect(find.text(value), findsOneWidget);
      }
    });

    testWidgets('displays all activities', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MissionSection(
              missionStatement: tMission,
              values: tValues,
              activities: tActivities,
            ),
          ),
        ),
      );

      expect(find.text('Lo que hacemos:'), findsOneWidget);
      for (final activity in tActivities) {
        expect(find.text(activity), findsOneWidget);
      }
    });

    testWidgets('handles empty values and activities lists', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MissionSection(
              missionStatement: tMission,
              values: [],
              activities: [],
            ),
          ),
        ),
      );

      expect(find.text(tMission), findsOneWidget);
      expect(find.text('Creemos que:'), findsOneWidget);
      expect(find.text('Lo que hacemos:'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline), findsNothing);
      expect(find.byIcon(Icons.bolt), findsNothing);
    });
  });
}
