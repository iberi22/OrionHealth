import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/about/presentation/widgets/mission_section.dart';
import '../../../../core/golden_test_utils.dart';

void main() {
  group('MissionSection Golden Test', () {
    testWidgets('MissionSection - Standard', (tester) async {
      setupGoldenTest(tester);

      await tester.pumpWidget(
        wrapWithMaterial(
          const Scaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: MissionSection(
                  missionStatement: 'Empoderar a las personas con herramientas digitales para gestionar su salud de manera proactiva, segura y descentralizada.',
                  values: [
                    'La privacidad del paciente es innegociable',
                    'Tecnología accesible para todos',
                    'Datos seguros, soberanía del usuario',
                  ],
                  activities: [
                    'Desarrollo de wallet de salud con estándares FHIR',
                    'Integración con sistemas de salud colombianos (EPS)',
                    'Investigación en IA para diagnósticos asistidos',
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      await expectLater(
        find.byType(MissionSection),
        matchesGoldenFile("../../../../../golden/reference/mission_section.png"),
      );
      resetGoldenTest(tester);
    });
  });
}
