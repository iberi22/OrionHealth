import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/doctor_verification/application/doctor_verification_cubit.dart';
import 'package:orionhealth_health/features/doctor_verification/application/doctor_verification_state.dart';
import 'package:orionhealth_health/features/doctor_verification/presentation/pages/doctor_detail_page.dart';
import 'package:orionhealth_health/features/doctor_verification/domain/entities/doctor_profile.dart';
import 'package:orionhealth_health/core/di/injection.dart';

class MockDoctorVerificationCubit extends Mock implements DoctorVerificationCubit {}

void main() {
  late MockDoctorVerificationCubit mockCubit;
  late DoctorProfile verifiedDoctor;
  late DoctorProfile unverifiedDoctor;
  final tDate = DateTime(2023, 1, 1);

  setUp(() {
    mockCubit = MockDoctorVerificationCubit();
    when(() => mockCubit.loadDoctors()).thenAnswer((_) async {});
    when(() => mockCubit.stream).thenAnswer(
      (_) => const Stream.empty(),
    );
    when(() => mockCubit.close()).thenAnswer((_) async {});

    getIt.reset();
    getIt.registerSingleton<DoctorVerificationCubit>(mockCubit);

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

  tearDown(() {
    getIt.reset();
  });

  Widget createWidgetUnderTest(DoctorProfile doctor) {
    return MaterialApp(
      home: DoctorDetailPage(doctor: doctor),
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
  });
}
