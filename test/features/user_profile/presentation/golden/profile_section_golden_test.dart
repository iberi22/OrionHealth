import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/user_profile/presentation/widgets/profile_section.dart';
import 'package:orionhealth_health/features/user_profile/presentation/widgets/profile_info_tile.dart';
import '../../../../core/golden_test_utils.dart';

void main() {
  group('ProfileSection Golden Tests', () {
    testWidgets('ProfileSection - Default', (tester) async {
      setupGoldenTest(tester);

      await tester.pumpWidget(wrapWithMaterial(
        const ProfileSection(
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
          ],
        ),
      ));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(ProfileSection),
        matchesGoldenFile("goldens/profile_section_default.png"),
      );
      resetGoldenTest(tester);
    });
  });
}
