import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/user_profile/presentation/widgets/profile_section.dart';
import 'package:orionhealth_health/features/user_profile/presentation/widgets/profile_info_tile.dart';
import '../../../../core/golden_test_utils.dart';

void main() {
  group('ProfileSection Golden Tests', () {
    testWidgets('ProfileSection with several info tiles', (tester) async {
      setupGoldenTest(tester);

      await tester.pumpWidget(
        wrapWithMaterial(
          const Scaffold(
            body: SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: ProfileSection(
                title: 'Información Personal',
                children: [
                  ProfileInfoTile(
                    icon: Icons.person,
                    title: 'Nombre Completo',
                    subtitle: 'Alex Damon',
                  ),
                  ProfileInfoTile(
                    icon: Icons.cake,
                    title: 'Fecha de Nacimiento',
                    subtitle: '15 de Agosto, 1988',
                  ),
                  ProfileInfoTile(
                    icon: Icons.call,
                    title: 'Número de Contacto',
                    subtitle: '+1 (555) 123-4567',
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(ProfileSection),
        matchesGoldenFile("../../../../../golden/reference/profile_section_info.png"),
      );
      resetGoldenTest(tester);
    });
  });
}
