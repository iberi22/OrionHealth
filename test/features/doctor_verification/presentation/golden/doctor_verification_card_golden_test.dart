import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/doctor_verification/domain/entities/doctor_profile.dart';
import 'package:orionhealth_health/features/doctor_verification/presentation/pages/doctor_verification_card.dart';
import '../../../../core/golden_test_utils.dart';

void main() {
  testWidgets('DoctorVerificationCard golden test - unverified', (tester) async {
    setupGoldenTest(tester);

    final unverifiedDoctor = DoctorProfile(
      id: 'doc-123',
      fullName: 'Dr. Jane Smith',
      specialty: 'Cardiologist',
      licenseNumber: 'MD12345',
      countryCode: 'US',
      verified: false,
      createdAt: DateTime(2023, 1, 1),
      updatedAt: DateTime(2023, 1, 1),
    );

    await tester.pumpWidget(
      wrapWithMaterial(
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: DoctorVerificationCard(doctor: unverifiedDoctor),
          ),
        ),
      ),
    );

    await expectLater(
      find.byType(DoctorVerificationCard),
      matchesGoldenFile('goldens/doctor_verification_card_unverified.png'),
    );

    resetGoldenTest(tester);
  });

  testWidgets('DoctorVerificationCard golden test - verified', (tester) async {
    setupGoldenTest(tester);

    final verifiedDoctor = DoctorProfile(
      id: 'doc-123',
      fullName: 'Dr. Jane Smith',
      specialty: 'Cardiologist',
      licenseNumber: 'MD12345',
      countryCode: 'US',
      verified: true,
      createdAt: DateTime(2023, 1, 1),
      updatedAt: DateTime(2023, 1, 1),
    );

    await tester.pumpWidget(
      wrapWithMaterial(
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: DoctorVerificationCard(doctor: verifiedDoctor),
          ),
        ),
      ),
    );

    await expectLater(
      find.byType(DoctorVerificationCard),
      matchesGoldenFile('goldens/doctor_verification_card_verified.png'),
    );

    resetGoldenTest(tester);
  });
}
