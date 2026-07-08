import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/doctor_verification/presentation/widgets/verification_badge.dart';
import '../../../../core/golden_test_utils.dart';

void main() {
  testWidgets('VerificationBadge golden test - verified', (tester) async {
    setupGoldenTest(tester);

    await tester.pumpWidget(
      wrapWithMaterial(
        const Scaffold(
          body: Center(
            child: VerificationBadge(isVerified: true),
          ),
        ),
      ),
    );

    await expectLater(
      find.byType(VerificationBadge),
      matchesGoldenFile('goldens/verification_badge_verified.png'),
    );

    resetGoldenTest(tester);
  });

  testWidgets('VerificationBadge golden test - unverified', (tester) async {
    setupGoldenTest(tester);

    await tester.pumpWidget(
      wrapWithMaterial(
        const Scaffold(
          body: Center(
            child: VerificationBadge(isVerified: false),
          ),
        ),
      ),
    );

    await expectLater(
      find.byType(VerificationBadge),
      matchesGoldenFile('goldens/verification_badge_unverified.png'),
    );

    resetGoldenTest(tester);
  });
}
