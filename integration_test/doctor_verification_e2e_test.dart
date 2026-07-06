import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:orionhealth_health/core/di/injection.dart' as di;
import 'package:orionhealth_health/features/doctor_verification/presentation/pages/doctor_list_page.dart';
import 'package:orionhealth_health/features/doctor_verification/presentation/pages/doctor_detail_page.dart';
import 'package:orionhealth_health/features/doctor_verification/domain/entities/doctor_profile.dart';
import 'package:orionhealth_health/features/doctor_verification/domain/repositories/doctor_profile_repository.dart';
import 'package:orionhealth_health/features/doctor_verification/domain/repositories/rating_repository.dart';
import 'package:orionhealth_health/features/doctor_verification/domain/services/license_verifier.dart';
import 'package:orionhealth_health/features/doctor_verification/presentation/widgets/doctor_card.dart';
import 'package:orionhealth_health/features/doctor_verification/presentation/widgets/rating_dialog.dart';
import 'package:mocktail/mocktail.dart';
import 'dart:async';
import 'package:orionhealth_health/features/doctor_verification/domain/entities/doctor_rating.dart';
import 'utils/video_recorder.dart';

class MockDoctorProfileRepository extends Mock implements DoctorProfileRepository {}
class MockRatingRepository extends Mock implements RatingRepository {}
class MockLicenseVerifier extends Mock implements LicenseVerifier {}

class FakeDoctorRating extends Fake implements DoctorRating {}
class FakeDoctorProfile extends Fake implements DoctorProfile {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockDoctorProfileRepository mockProfileRepo;
  late MockRatingRepository mockRatingRepo;
  late MockLicenseVerifier mockLicenseVerifier;

  final doctor = DoctorProfile(
    id: 'dr1',
    fullName: 'Dr. Gregory House',
    specialty: 'Diagnostic Medicine',
    licenseNumber: 'MD-12345',
    countryCode: 'US',
    institution: 'Princeton-Plainsboro',
    yearsOfExperience: 20,
    languages: ['English'],
    verified: false,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  setUpAll(() async {
    await di.configureDependencies();
    registerFallbackValue(FakeDoctorRating());
    registerFallbackValue(FakeDoctorProfile());
  });

  setUp(() {
    mockProfileRepo = MockDoctorProfileRepository();
    mockRatingRepo = MockRatingRepository();
    mockLicenseVerifier = MockLicenseVerifier();

    di.getIt.allowReassignment = true;
    di.getIt.registerSingleton<DoctorProfileRepository>(mockProfileRepo);
    di.getIt.registerSingleton<RatingRepository>(mockRatingRepo);
    di.getIt.registerSingleton<LicenseVerifier>(mockLicenseVerifier);

    when(() => mockProfileRepo.getAllDoctorProfiles()).thenAnswer((_) async => [doctor]);
    when(() => mockRatingRepo.getAverageForDoctor(any())).thenAnswer((_) async => 4.5);
  });

  group('Doctor Verification - True E2E Tests', () {
    testWidgets('E2E: Doctor List and Detail Navigation', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: DoctorListPage(),
      ));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'doctor_verif', '01_list_loaded');

      expect(find.text('Dr. Gregory House'), findsOneWidget);
      expect(find.text('Diagnostic Medicine'), findsOneWidget);

      await tester.tap(find.byType(DoctorCard));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'doctor_verif', '02_detail_page');

      expect(find.text('MD-12345'), findsOneWidget);
      expect(find.text('Princeton-Plainsboro'), findsOneWidget);
    });

    testWidgets('E2E: Submit Rating', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      when(() => mockRatingRepo.save(any())).thenAnswer((_) async {});

      await tester.pumpWidget(MaterialApp(
        home: DoctorDetailPage(doctor: doctor),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('DEJAR UNA RESEÑA'));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'doctor_verif', '03_rating_dialog');

      expect(find.byType(RatingDialog), findsOneWidget);

      await tester.tap(find.text('ENVIAR'));
      await tester.pumpAndSettle();

      verify(() => mockRatingRepo.save(any())).called(1);
    });

    testWidgets('E2E: Verify License Flow', (WidgetTester tester) async {
      when(() => mockLicenseVerifier.verify(any(), any()))
          .thenAnswer((_) async => LicenseVerificationResult.valid);
      when(() => mockProfileRepo.saveDoctorProfile(any())).thenAnswer((_) async {});

      await tester.pumpWidget(MaterialApp(
        home: DoctorDetailPage(doctor: doctor),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('VERIFICAR LICENCIA AHORA'));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'doctor_verif', '04_verification_triggered');

      verify(() => mockLicenseVerifier.verify('MD-12345', 'US')).called(1);
    });

    testWidgets('E2E: Error Snackbar on Verification Failure', (WidgetTester tester) async {
      when(() => mockLicenseVerifier.verify(any(), any()))
          .thenThrow(Exception('Verification Failed'));

      await tester.pumpWidget(const MaterialApp(
        home: DoctorDetailPage(doctor: doctor),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('VERIFICAR LICENCIA AHORA'));
      await tester.pump(); // SnackBar trigger

      expect(find.textContaining('Verification Failed'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'doctor_verif', '05_error_snackbar');
    });
  });
}
