import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/doctor_verification/presentation/widgets/verification_badge.dart';

void main() {
  testWidgets('VerificationBadge shows verified text when isVerified is true', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: VerificationBadge(isVerified: true),
      ),
    ));

    expect(find.text('MÉDICO VERIFICADO'), findsOneWidget);
    expect(find.byIcon(Icons.verified), findsOneWidget);
  });

  testWidgets('VerificationBadge shows pending text when isVerified is false', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: VerificationBadge(isVerified: false),
      ),
    ));

    expect(find.text('PENDIENTE DE VERIFICACIÓN'), findsOneWidget);
    expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
  });
}
