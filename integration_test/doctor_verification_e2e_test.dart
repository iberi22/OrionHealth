import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:orionhealth_health/features/doctor_verification/presentation/pages/doctor_list_page.dart';
import 'package:orionhealth_health/features/doctor_verification/presentation/pages/doctor_detail_page.dart';
import 'package:orionhealth_health/features/doctor_verification/domain/entities/doctor_profile.dart';
import 'package:orionhealth_health/features/doctor_verification/application/doctor_verification_cubit.dart';
import 'package:orionhealth_health/features/doctor_verification/application/doctor_verification_state.dart';
import 'package:orionhealth_health/features/doctor_verification/presentation/widgets/doctor_card.dart';
import 'package:orionhealth_health/features/doctor_verification/presentation/widgets/rating_dialog.dart';
import 'package:mocktail/mocktail.dart';
import 'dart:async';
import 'package:get_it/get_it.dart';
import 'package:orionhealth_health/features/doctor_verification/domain/entities/doctor_rating.dart';
import 'utils/video_recorder.dart';

class MockDoctorVerificationCubit extends Mock implements DoctorVerificationCubit {
  @override
  Future<void> close() async {}
}

class FakeDoctorRating extends Fake implements DoctorRating {}

class FakeDoctorProfile extends Fake implements DoctorProfile {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(FakeDoctorRating());
    registerFallbackValue(FakeDoctorProfile());
  });

  late MockDoctorVerificationCubit mockCubit;
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

  setUp(() {
    mockCubit = MockDoctorVerificationCubit();
    GetIt.I.registerSingleton<DoctorVerificationCubit>(mockCubit);

    when(() => mockCubit.loadDoctors()).thenAnswer((_) async {});
    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
  });

  tearDown(() {
    GetIt.I.unregister<DoctorVerificationCubit>();
  });

  group('Doctor Verification - E2E Tests', () {
    testWidgets('E2E: Doctor List and Detail Navigation', (WidgetTester tester) async {
      when(() => mockCubit.state).thenReturn(DoctorVerificationLoaded(
        doctors: [doctor],
        averageRatings: const {'dr1': 4.5},
      ));

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

      when(() => mockCubit.state).thenReturn(DoctorVerificationLoaded(
        doctors: [doctor],
        averageRatings: const {'dr1': 4.5},
      ));
      when(() => mockCubit.submitRating(any())).thenAnswer((_) async {});

      await tester.pumpWidget(MaterialApp(
        home: DoctorDetailPage(doctor: doctor),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('DEJAR UNA RESEÑA'));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'doctor_verif', '03_rating_dialog');

      expect(find.byType(RatingDialog), findsOneWidget);

      // Simulate rating selection (finding stars might be tricky, let's look for submit)
      await tester.tap(find.text('ENVIAR'));
      await tester.pumpAndSettle();

      verify(() => mockCubit.submitRating(any())).called(1);
    });

    testWidgets('E2E: Verify License Flow', (WidgetTester tester) async {
      when(() => mockCubit.state).thenReturn(DoctorVerificationLoaded(
        doctors: [doctor],
        averageRatings: const {'dr1': 4.5},
      ));
      when(() => mockCubit.verifyDoctor(any())).thenAnswer((_) async {});

      await tester.pumpWidget(MaterialApp(
        home: DoctorDetailPage(doctor: doctor),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('VERIFICAR LICENCIA AHORA'));
      await tester.pump();
      await VideoRecorder.recordStep(tester, 'doctor_verif', '04_verification_triggered');

      verify(() => mockCubit.verifyDoctor(doctor)).called(1);
    });
   group('Edge Cases', () {
      testWidgets('Error Snackbar on Verification Failure', (WidgetTester tester) async {
        final stateController = StreamController<DoctorVerificationState>.broadcast();
        when(() => mockCubit.state).thenReturn(DoctorVerificationInitial());
        when(() => mockCubit.stream).thenAnswer((_) => stateController.stream);

        await tester.pumpWidget(MaterialApp(
          home: DoctorDetailPage(doctor: doctor),
        ));
        await tester.pumpAndSettle();

        stateController.add(const DoctorVerificationError('Verification Failed'));
        await tester.pump(); // SnackBar trigger

        expect(find.text('Verification Failed'), findsOneWidget);
        await VideoRecorder.recordStep(tester, 'doctor_verif', '05_error_snackbar');
      });
    });
  });
}
