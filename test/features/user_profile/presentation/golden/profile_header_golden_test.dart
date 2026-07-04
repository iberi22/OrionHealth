import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/user_profile/domain/entities/user_profile.dart';
import 'package:orionhealth_health/features/user_profile/presentation/widgets/profile_header.dart';
import '../../../../core/golden_test_utils.dart';

void main() {
  group('ProfileHeader Golden Tests', () {
    testWidgets('ProfileHeader with name and default avatar', (tester) async {
      setupGoldenTest(tester);

      final profile = UserProfile(
        name: 'Alex Damon',
        email: 'alex.damon@orion.health',
      );

      await tester.pumpWidget(
        wrapWithMaterial(
          Scaffold(
            body: Center(
              child: ProfileHeader(userProfile: profile),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(ProfileHeader),
        matchesGoldenFile("../../../../../golden/reference/profile_header_default.png"),
      );
      resetGoldenTest(tester);
    });
  });
}
