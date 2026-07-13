import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/settings/presentation/widgets/profile_section.dart';
import 'package:orionhealth_health/features/user_profile/domain/entities/user_profile.dart';

import '../../../../core/golden_test_utils.dart';

void main() {
  group('ProfileSection Golden Tests', () {
    final testProfile = UserProfile(
      name: 'John Doe',
      email: 'john.doe@example.com',
    );

    testWidgets('Profile Section - Dark Mode', (WidgetTester tester) async {
      setupGoldenTest(tester, size: const Size(400, 300));

      await tester.pumpWidget(
        wrapWithMaterial(
          Scaffold(
            body: ProfileSection(
              userProfile: testProfile,
              isDarkMode: true,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await expectLater(
        find.byType(ProfileSection),
        matchesGoldenFile('goldens/profile_section.png'),
      );
    });
  });
}
