import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/about/presentation/widgets/mission_section.dart';
import '../../../../core/golden_test_utils.dart';

void main() {
  group('MissionSection Golden Test', () {
    testWidgets('MissionSection renders correctly', (tester) async {
      setupGoldenTest(tester);

      const missionSection = MissionSection(
        missionStatement: 'Nuestra misión es transformar la salud a través de la tecnología y el acceso universal.',
        values: [
          'Privacidad por diseño',
          'Empoderamiento del paciente',
          'Excelencia clínica',
        ],
        activities: [
          'Desarrollo de IA para diagnóstico',
          'Integración de registros médicos universales',
          'Seguimiento preventivo proactivo',
        ],
      );

      await tester.pumpWidget(wrapWithMaterial(
        const SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: missionSection,
          ),
        ),
      ));

      await expectLater(
        find.byType(MissionSection),
        matchesGoldenFile("../../../../golden/reference/mission_section.png"),
      );
      resetGoldenTest(tester);
    });
  });
}
