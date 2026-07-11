import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:orionhealth_health/features/doctor_verification/presentation/pages/doctor_list_page.dart';
import 'package:orionhealth_health/features/doctor_verification/application/doctor_verification_cubit.dart';
import 'package:orionhealth_health/features/doctor_verification/application/doctor_verification_state.dart';
import 'package:orionhealth_health/features/doctor_verification/domain/entities/doctor_profile.dart';
import 'package:orionhealth_health/core/di/injection.dart';
import '../../../../core/golden_test_utils.dart';

class MockDoctorVerificationCubit extends Mock implements DoctorVerificationCubit {}

void main() {
  late MockDoctorVerificationCubit mockCubit;
  final now = DateTime(2024, 1, 1);
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

  setUpAll(() {
    getIt.allowReassignment = true;
  });

  setUp(() {
    mockCubit = MockDoctorVerificationCubit();
    getIt.registerSingleton<DoctorVerificationCubit>(mockCubit);

    when(() => mockCubit.loadDoctors()).thenAnswer((_) async => {});
    when(() => mockCubit.close()).thenAnswer((_) async => {});
    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
  });

  tearDown(() {
    getIt.reset();
  });

  testWidgets('DoctorListPage golden test', (tester) async {
    setupGoldenTest(tester);
    when(() => mockCubit.state).thenReturn(DoctorVerificationLoaded(
      doctors: [doctorVerified],
      averageRatings: {'1': 4.5},
    ));

    await tester.pumpWidget(
      wrapWithMaterial(const DoctorListPage()),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(DoctorListPage),
      matchesGoldenFile('goldens/doctor_list_page.png'),
    );
    resetGoldenTest(tester);
  });
}
