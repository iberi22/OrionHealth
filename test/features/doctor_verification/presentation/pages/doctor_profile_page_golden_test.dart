import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:orionhealth_health/features/doctor_verification/presentation/pages/doctor_list_page.dart';
import 'package:orionhealth_health/features/doctor_verification/presentation/pages/doctor_detail_page.dart';
import 'package:orionhealth_health/features/doctor_verification/presentation/widgets/rating_dialog.dart';
import 'package:orionhealth_health/features/doctor_verification/application/doctor_verification_cubit.dart';
import 'package:orionhealth_health/features/doctor_verification/application/doctor_verification_state.dart';
import 'package:orionhealth_health/features/doctor_verification/domain/entities/doctor_profile.dart';
import '../../../../core/golden_test_utils.dart';

class MockDoctorVerificationCubit extends Mock implements DoctorVerificationCubit {
  @override
  Future<void> close() async {}
}

void main() {
  late MockDoctorVerificationCubit mockCubit;
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
    institution: 'St. Bartholomew\'s',
    yearsOfExperience: 10,
    languages: ['English'],
    createdAt: now,
    updatedAt: now,
    countryCode: 'UK',
  );

  setUpAll(() {
    mockCubit = MockDoctorVerificationCubit();
    GetIt.I.registerSingleton<DoctorVerificationCubit>(mockCubit);
  });

  tearDownAll(() {
    GetIt.I.reset();
  });

  group('Doctor Verification Golden Tests', () {
    testWidgets('Doctor List Page', (tester) async {
      setupGoldenTest(tester);
      when(() => mockCubit.state).thenReturn(DoctorVerificationLoaded(
        doctors: [doctorVerified, doctorUnverified],
        averageRatings: {'1': 4.5, '2': 3.8},
      ));
      when(() => mockCubit.loadDoctors()).thenAnswer((_) async {});
      when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(wrapWithMaterial(const DoctorListPage()));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(DoctorListPage),
        matchesGoldenFile('goldens/doctor_list_page.png'),
      );
      resetGoldenTest(tester);
    });

    testWidgets('Doctor Detail Page - Verified', (tester) async {
      setupGoldenTest(tester);
      when(() => mockCubit.state).thenReturn(DoctorVerificationLoaded(
        doctors: [doctorVerified],
        averageRatings: {'1': 4.5},
      ));
      when(() => mockCubit.loadDoctors()).thenAnswer((_) async {});
      when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(wrapWithMaterial(DoctorDetailPage(doctor: doctorVerified)));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(DoctorDetailPage),
        matchesGoldenFile('goldens/doctor_detail_verified.png'),
      );
      resetGoldenTest(tester);
    });

    testWidgets('Doctor Detail Page - Unverified', (tester) async {
      setupGoldenTest(tester);
      when(() => mockCubit.state).thenReturn(DoctorVerificationLoaded(
        doctors: [doctorUnverified],
        averageRatings: {'2': 3.8},
      ));

      await tester.pumpWidget(wrapWithMaterial(DoctorDetailPage(doctor: doctorUnverified)));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(DoctorDetailPage),
        matchesGoldenFile('goldens/doctor_detail_unverified.png'),
      );
      resetGoldenTest(tester);
    });

    testWidgets('Rating Dialog', (tester) async {
      setupGoldenTest(tester);

      await tester.pumpWidget(wrapWithMaterial(
        Scaffold(
          body: RatingDialog(
            doctorId: '1',
            onSubmitted: (_) {},
          ),
        ),
      ));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(RatingDialog),
        matchesGoldenFile('goldens/rating_dialog.png'),
      );
      resetGoldenTest(tester);
    });
  });
}
