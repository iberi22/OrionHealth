import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/doctor_verification/presentation/widgets/verification_badge.dart';

void main() {
  testWidgets('VerificationBadge golden test', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: VerificationBadge())),
    );
    await expectLater(
      find.byType(VerificationBadge),
      matchesGoldenFile('goldens/verification_badge.png'),
    );
  });
}
