import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/doctor_verification/application/doctor_verification_cubit.dart';
import 'package:orionhealth_health/features/doctor_verification/application/doctor_verification_state.dart';
import 'package:orionhealth_health/features/doctor_verification/presentation/pages/doctor_detail_page.dart';
import 'package:orionhealth_health/features/doctor_verification/domain/entities/doctor_profile.dart';

class MockDoctorVerificationCubit extends Mock implements DoctorVerificationCubit {}

void main() {
  late MockDoctorVerificationCubit mockCubit;
  late DoctorProfile verifiedDoctor;
  late DoctorProfile unverifiedDoctor;
  final tDate = DateTime(2023, 1, 1);

  setUp(() {
    mockCubit = MockDoctorVerificationCubit();
    when(() => mockCubit.stream).thenAnswer(
      (_) => const Stream.empty(),
    );
    when(() => mockCubit.close()).thenAnswer((_) async {});

    verifiedDoctor = DoctorProfile(
      id: '1',
      fullName: 'Dr. Verified',
      specialty: 'Cardiology',
      licenseNumber: 'LIC-12345',
      countryCode: 'US',
      institution: 'General Hospital',
      yearsOfExperience: 10,
      languages: ['English', 'Spanish'],
      verified: true,
      createdAt: tDate,
      updatedAt: tDate,
    );

    unverifiedDoctor = DoctorProfile(
      id: '2',
      fullName: 'Dr. Pending',
      specialty: 'Neurology',
      licenseNumber: 'LIC-67890',
      countryCode: 'CO',
      institution: 'San Vicente',
      yearsOfExperience: 5,
      languages: ['Spanish'],
      verified: false,
      createdAt: tDate,
      updatedAt: tDate,
    );
  });

  Widget createWidgetUnderTest(DoctorProfile doctor) {
    return MaterialApp(
      home: BlocProvider<DoctorVerificationCubit>.value(
        value: mockCubit,
        child: DoctorDetailPage(doctor: doctor),
      ),
    );
  }

  group('DoctorDetailPage', () {
    testWidgets('renders doctor name and specialty', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(verifiedDoctor));
      await tester.pump();

      expect(find.text('Dr. Verified'), findsOneWidget);
      expect(find.text('Cardiology'), findsOneWidget);
    });

    testWidgets('shows verified badge for verified doctor', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(verifiedDoctor));
      await tester.pump();

      expect(find.text('MÉDICO VERIFICADO'), findsOneWidget);
    });

    testWidgets('shows pending verification for unverified doctor', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(unverifiedDoctor));
      await tester.pump();

      expect(find.text('PENDIENTE DE VERIFICACIÓN'), findsOneWidget);
    });

    testWidgets('shows verify button only for unverified doctor', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(unverifiedDoctor));
      await tester.pump();

      expect(find.text('VERIFICAR LICENCIA AHORA'), findsOneWidget);
    });

    testWidgets('hides verify button for verified doctor', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(verifiedDoctor));
      await tester.pump();

      expect(find.text('VERIFICAR LICENCIA AHORA'), findsNothing);
    });

    testWidgets('shows leave review button for all doctors', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(verifiedDoctor));
      await tester.pump();

      expect(find.text('DEJAR UNA RESEÑA'), findsOneWidget);
    });

    testWidgets('shows info sections with license and institution', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(verifiedDoctor));
      await tester.pump();

      expect(find.text('LIC-12345'), findsOneWidget);
      expect(find.text('General Hospital'), findsOneWidget);
      expect(find.text('10 años'), findsOneWidget);
      expect(find.text('English, Spanish'), findsOneWidget);
    });

    testWidgets('shows N/A for null fields on unverified doctor', (tester) async {
      final minimalDoctor = DoctorProfile(
        id: '3',
        fullName: 'Dr. Minimal',
        specialty: 'General',
        countryCode: 'US',
        licenseNumber: null,
        institution: null,
        yearsOfExperience: null,
        languages: const [],
        verified: false,
        createdAt: tDate,
        updatedAt: tDate,
      );

      await tester.pumpWidget(createWidgetUnderTest(minimalDoctor));
      await tester.pump();

      expect(find.text('N/A'), findsWidgets);
    });

    testWidgets('calls verifyDoctor when verify button is pressed', (tester) async {
      when(() => mockCubit.verifyDoctor(unverifiedDoctor)).thenAnswer((_) async {});

      await tester.pumpWidget(createWidgetUnderTest(unverifiedDoctor));
      await tester.pump();

      await tester.tap(find.text('VERIFICAR LICENCIA AHORA'));
      await tester.pump();

      verify(() => mockCubit.verifyDoctor(unverifiedDoctor)).called(1);
    });

    testWidgets('shows snackbar on license verification result', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(unverifiedDoctor));
      await tester.pump();

      // Manually trigger the listener by providing a new stream value
      // Since we're using BlocProvider.value, we need to simulate a state change
      // by providing a cubit that emits states
      final stateStream = Stream<DoctorVerificationState>.fromIterable([
        const LicenseVerificationResultState('valid'),
      ]);

      final emitCubit = MockDoctorVerificationCubit();
      when(() => emitCubit.stream).thenAnswer((_) => stateStream);
      when(() => emitCubit.state).thenReturn(const LicenseVerificationResultState('valid'));
      when(() => emitCubit.close()).thenAnswer((_) async {});

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<DoctorVerificationCubit>.value(
            value: emitCubit,
            child: DoctorDetailPage(doctor: unverifiedDoctor),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Verificación finalizada: VALID'), findsOneWidget);
    });

    testWidgets('shows error snackbar on error state', (tester) async {
      final stateStream = Stream<DoctorVerificationState>.fromIterable([
        const DoctorVerificationError('Verification failed'),
      ]);

      final errorCubit = MockDoctorVerificationCubit();
      when(() => errorCubit.stream).thenAnswer((_) => stateStream);
      when(() => errorCubit.state).thenReturn(const DoctorVerificationError('Verification failed'));
      when(() => errorCubit.close()).thenAnswer((_) async {});

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<DoctorVerificationCubit>.value(
            value: errorCubit,
            child: DoctorDetailPage(doctor: unverifiedDoctor),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Verification failed'), findsOneWidget);
    });

    testWidgets('verify button calls verifyDoctor on unverified doctor', (tester) async {
      when(() => mockCubit.verifyDoctor(unverifiedDoctor)).thenAnswer((_) async {});

      await tester.pumpWidget(createWidgetUnderTest(unverifiedDoctor));
      await tester.pump();

      await tester.tap(find.text('VERIFICAR LICENCIA AHORA'));
      await tester.pump();

      verify(() => mockCubit.verifyDoctor(unverifiedDoctor)).called(1);
    });
  });
}
