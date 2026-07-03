import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:orionhealth_health/features/doctor_verification/presentation/pages/doctor_profile_page.dart';
import 'package:orionhealth_health/features/doctor_verification/presentation/pages/doctor_verification_card.dart';
import 'package:orionhealth_health/features/doctor_verification/domain/entities/doctor_profile.dart';
import '../../../../core/golden_test_utils.dart';

void main() {
  final now = DateTime.now();
  final doctorVerified = DoctorProfile(
    id: '1',
    fullName: 'Dr. Gregory House',
    specialty: 'Diagnostic Medicine',
    verified: true,
    licenseNumber: 'MD12345',
    institution: 'Princeton-Plainsboro',
    yearsOfExperience: 20,
    languages: ['English', 'Spanish'],
    countryCode: 'US',
    createdAt: now,
    updatedAt: now,
  );
  final doctorUnverified = DoctorProfile(
    id: '2',
    fullName: 'Dr. John Watson',
    specialty: 'General Practice',
    verified: false,
    licenseNumber: 'MD67890',
    institution: "St. Bartholomew's",
    yearsOfExperience: 10,
    languages: ['English'],
    createdAt: now,
    updatedAt: now,
    countryCode: 'UK',
  );

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await GetIt.I.reset();
  });

  group('Doctor Profile Page Golden Tests', () {
    testWidgets('Profile Page with Verified Doctor', (tester) async {
      setupGoldenTest(tester);
      await tester.pumpWidget(wrapWithMaterial(DoctorProfilePage(doctor: doctorVerified)));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(DoctorProfilePage),
        matchesGoldenFile("../../../../golden/reference/doctor_profile_page.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('Doctor Verification Card - Verified', (tester) async {
      setupGoldenTest(tester);
      await tester.pumpWidget(wrapWithMaterial(
        Scaffold(body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: DoctorVerificationCard(doctor: doctorVerified),
        )),
      ));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(DoctorVerificationCard),
        matchesGoldenFile("../../../../golden/reference/doctor_profile_card.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('Doctor Verification Card - Unverified', (tester) async {
      setupGoldenTest(tester);
      await tester.pumpWidget(wrapWithMaterial(
        Scaffold(body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: DoctorVerificationCard(doctor: doctorUnverified),
        )),
      ));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(DoctorVerificationCard),
        matchesGoldenFile("../../../../golden/reference/doctor_verification_form.png"),
      );
      resetGoldenTest(tester);
    });
  });
}
