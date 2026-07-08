import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/doctor_verification/domain/entities/doctor_profile.dart';
import 'package:orionhealth_health/features/doctor_verification/domain/entities/verification_status.dart';
import 'package:orionhealth_health/features/doctor_verification/presentation/widgets/verification_card.dart';
import '../../../../core/golden_test_utils.dart';

void main() {
  final mockDoctor = DoctorProfile(
    id: 'doc-123',
    fullName: 'Dr. Jane Smith',
    specialty: 'Cardiologist',
    licenseNumber: 'MD12345',
    countryCode: 'US',
    verified: false,
    createdAt: DateTime(2023, 1, 1),
    updatedAt: DateTime(2023, 1, 1),
  );

  testWidgets('VerificationCard golden test - pending', (tester) async {
    setupGoldenTest(tester, size: const Size(600, 800)); // Increased size

    await tester.pumpWidget(
      wrapWithMaterial(
        Scaffold(
          body: Center(
            child: SizedBox(
              width: 500,
              child: VerificationCard(
                doctor: mockDoctor,
                status: VerificationStatus.pending,
                onVerify: () {},
              ),
            ),
          ),
        ),
      ),
    );

    await expectLater(
      find.byType(VerificationCard),
      matchesGoldenFile('goldens/verification_card_pending.png'),
    );

    resetGoldenTest(tester);
  });

  testWidgets('VerificationCard golden test - verified', (tester) async {
    setupGoldenTest(tester, size: const Size(600, 800)); // Increased size

    await tester.pumpWidget(
      wrapWithMaterial(
        Scaffold(
          body: Center(
            child: SizedBox(
              width: 500,
              child: VerificationCard(
                doctor: mockDoctor,
                status: VerificationStatus.verified,
                onVerify: () {},
              ),
            ),
          ),
        ),
      ),
    );

    await expectLater(
      find.byType(VerificationCard),
      matchesGoldenFile('goldens/verification_card_verified.png'),
    );

    resetGoldenTest(tester);
  });

  testWidgets('VerificationCard golden test - rejected', (tester) async {
    setupGoldenTest(tester, size: const Size(600, 800)); // Increased size

    await tester.pumpWidget(
      wrapWithMaterial(
        Scaffold(
          body: Center(
            child: SizedBox(
              width: 500,
              child: VerificationCard(
                doctor: mockDoctor,
                status: VerificationStatus.rejected,
                onVerify: () {},
              ),
            ),
          ),
        ),
      ),
    );

    await expectLater(
      find.byType(VerificationCard),
      matchesGoldenFile('goldens/verification_card_rejected.png'),
    );

    resetGoldenTest(tester);
  });
}
