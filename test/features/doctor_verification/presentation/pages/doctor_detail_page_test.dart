import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/doctor_verification/application/doctor_verification_cubit.dart';
import 'package:orionhealth_health/features/doctor_verification/application/doctor_verification_state.dart';
import 'package:orionhealth_health/features/doctor_verification/presentation/pages/doctor_detail_page.dart';
import 'package:orionhealth_health/features/doctor_verification/domain/entities/doctor_profile.dart';
import 'package:orionhealth_health/core/di/injection.dart';
import 'dart:async';

class MockDoctorVerificationCubit extends Mock implements DoctorVerificationCubit {
  final _stateController = StreamController<DoctorVerificationState>.broadcast();

  @override
  Stream<DoctorVerificationState> get stream => _stateController.stream;

  @override
  Future<void> close() => _stateController.close();

  void emit(DoctorVerificationState state) => _stateController.add(state);
}

void main() {
  late MockDoctorVerificationCubit mockCubit;
  late DoctorProfile verifiedDoctor;
  late DoctorProfile unverifiedDoctor;
  final tDate = DateTime(2023, 1, 1);

  setUpAll(() {
    getIt.reset();
    mockCubit = MockDoctorVerificationCubit();
    getIt.registerSingleton<DoctorVerificationCubit>(mockCubit);
  });

  setUp(() {
    reset(mockCubit);
    when(() => mockCubit.loadDoctors()).thenAnswer((_) async {});

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
      home: DoctorDetailPage(doctor: doctor),
    );
  }

  group('DoctorDetailPage', () {
    testWidgets('renders doctor name and specialty', (tester) async {
      when(() => mockCubit.state).thenReturn(DoctorVerificationInitial());

      await tester.pumpWidget(createWidgetUnderTest(verifiedDoctor));
      await tester.pumpAndSettle();

      expect(find.text('Dr. Verified'), findsOneWidget);
      expect(find.text('Cardiology'), findsOneWidget);
    });

    testWidgets('shows verified badge for verified doctor', (tester) async {
      when(() => mockCubit.state).thenReturn(DoctorVerificationInitial());

      await tester.pumpWidget(createWidgetUnderTest(verifiedDoctor));
      await tester.pumpAndSettle();

      expect(find.text('MÉDICO VERIFICADO'), findsOneWidget);
    });

    testWidgets('shows pending verification for unverified doctor', (tester) async {
      when(() => mockCubit.state).thenReturn(DoctorVerificationInitial());

      await tester.pumpWidget(createWidgetUnderTest(unverifiedDoctor));
      await tester.pumpAndSettle();

      expect(find.text('PENDIENTE DE VERIFICACIÓN'), findsOneWidget);
    });

    testWidgets('shows verify button only for unverified doctor', (tester) async {
      when(() => mockCubit.state).thenReturn(DoctorVerificationInitial());

      await tester.pumpWidget(createWidgetUnderTest(unverifiedDoctor));
      await tester.pumpAndSettle();

      expect(find.text('VERIFICAR LICENCIA AHORA'), findsOneWidget);
    });

    testWidgets('hides verify button for verified doctor', (tester) async {
      when(() => mockCubit.state).thenReturn(DoctorVerificationInitial());

      await tester.pumpWidget(createWidgetUnderTest(verifiedDoctor));
      await tester.pumpAndSettle();

      expect(find.text('VERIFICAR LICENCIA AHORA'), findsNothing);
    });

    testWidgets('shows leave review button for all doctors', (tester) async {
      when(() => mockCubit.state).thenReturn(DoctorVerificationInitial());

      await tester.pumpWidget(createWidgetUnderTest(verifiedDoctor));
      await tester.pumpAndSettle();

      expect(find.text('DEJAR UNA RESEÑA'), findsOneWidget);
    });

    testWidgets('shows info sections with license and institution', (tester) async {
      when(() => mockCubit.state).thenReturn(DoctorVerificationInitial());

      await tester.pumpWidget(createWidgetUnderTest(verifiedDoctor));
      await tester.pumpAndSettle();

      expect(find.text('Licencia:'), findsOneWidget);
      expect(find.text('LIC-12345'), findsOneWidget);
      expect(find.text('Institución:'), findsOneWidget);
      expect(find.text('General Hospital'), findsOneWidget);
    });

    testWidgets('calls verifyDoctor when verify button is pressed', (tester) async {
      when(() => mockCubit.state).thenReturn(DoctorVerificationInitial());
      when(() => mockCubit.verifyDoctor(unverifiedDoctor)).thenAnswer((_) async {});

      await tester.pumpWidget(createWidgetUnderTest(unverifiedDoctor));
      await tester.pumpAndSettle();

      await tester.tap(find.text('VERIFICAR LICENCIA AHORA'));
      await tester.pumpAndSettle();

      verify(() => mockCubit.verifyDoctor(unverifiedDoctor)).called(1);
    });

    testWidgets('shows snackbar on license verification result', (tester) async {
      when(() => mockCubit.state).thenReturn(DoctorVerificationInitial());

      await tester.pumpWidget(createWidgetUnderTest(unverifiedDoctor));
      await tester.pumpAndSettle();

      // Update state to show license verification result
      mockCubit.emit(const LicenseVerificationResultState('valid'));
      await tester.pumpAndSettle();

      expect(find.text('Verificación finalizada: VALID'), findsOneWidget);
    });

    testWidgets('shows error snackbar on error state', (tester) async {
      when(() => mockCubit.state).thenReturn(DoctorVerificationInitial());

      await tester.pumpWidget(createWidgetUnderTest(unverifiedDoctor));
      await tester.pumpAndSettle();

      mockCubit.emit(const DoctorVerificationError('Verification failed'));
      await tester.pumpAndSettle();

      expect(find.text('Verification failed'), findsOneWidget);
    });

    testWidgets('verify button calls verifyDoctor', (tester) async {
      when(() => mockCubit.state).thenReturn(DoctorVerificationInitial());
      when(() => mockCubit.verifyDoctor(unverifiedDoctor)).thenAnswer((_) async {});

      await tester.pumpWidget(createWidgetUnderTest(unverifiedDoctor));
      await tester.pumpAndSettle();

      await tester.tap(find.text('VERIFICAR LICENCIA AHORA'));
      await tester.pumpAndSettle();

      verify(() => mockCubit.verifyDoctor(unverifiedDoctor)).called(1);
    });
  });
}
