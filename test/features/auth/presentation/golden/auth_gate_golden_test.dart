import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:orionhealth_health/features/auth/presentation/auth_gate.dart';
import '../../../../core/golden_test_utils.dart';

void main() {
  group('AuthGate Golden Tests', () {
    testWidgets('AuthGate - loading state (no user profile yet)', (tester) async {
      setupGoldenTest(tester);

      // AuthGate uses FutureBuilder to check UserProfileRepository.getUserProfile()
      // When no user profile is found, it shows onboarding
      // The default state shows CircularProgressIndicator
      await tester.pumpWidget(wrapWithMaterial(const AuthGate()));
      await tester.pump();

      await expectLater(
        find.byType(AuthGate),
        matchesGoldenFile('goldens/auth_gate_loading.png'),
      );
      resetGoldenTest(tester);
    });
  });
}
