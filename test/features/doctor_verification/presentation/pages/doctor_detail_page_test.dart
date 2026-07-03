import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/doctor_verification/application/doctor_verification_cubit.dart';
import 'package:orionhealth_health/features/doctor_verification/application/doctor_verification_state.dart';
import 'package:orionhealth_health/features/doctor_verification/presentation/pages/doctor_detail_page.dart';
import 'package:orionhealth_health/features/doctor_verification/domain/entities/doctor_profile.dart';
import 'package:get_it/get_it.dart';

class MockDoctorVerificationCubit extends Mock implements DoctorVerificationCubit {
  @override
  Future<void> close() async {}
}
class FakeDoctorProfile extends Fake implements DoctorProfile {}

void main() {
  late MockDoctorVerificationCubit mockCubit;
  late DoctorProfile verifiedDoctor;
  late DoctorProfile unverifiedDoctor;
  final tDate = DateTime(2023, 1, 1);

  setUpAll(() {
    registerFallbackValue(FakeDoctorProfile());
  });

  setUp(() async {
    await GetIt.I.reset();
    mockCubit = MockDoctorVerificationCubit();
    GetIt.I.registerSingleton<DoctorVerificationCubit>(mockCubit);

    when(() => mockCubit.stream).thenAnswer(
      (_) => const Stream.empty(),
    );
    when(() => mockCubit.state).thenReturn(const DoctorVerificationInitial());
    when(() => mockCubit.loadDoctors()).thenAnswer((_) async {});

    verifiedDoctor = DoctorProfile(
      id: '1',
      fullName: 'Dr. Verified',
      specialty: 'Cardiology',
      licenseNumber: 'LIC-12345',
      countryCode: 'US',
      institution: 'General Hospital',
      yearsOfExperience: 10,
      languages: const ['English', 'Spanish'],
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
      languages: const ['Spanish'],
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
      await tester.pumpWidget(createWidgetUnderTest(verifiedDoctor));
      await tester.pump();

      expect(find.text('Dr. Verified'), findsWidgets);
      expect(find.text('Cardiology'), findsWidgets);
    });

    testWidgets('shows verified status correctly', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(verifiedDoctor));
      await tester.pump();

      expect(find.text('Verificado'), findsOneWidget);
    });

    testWidgets('shows unverified status correctly', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(unverifiedDoctor));
      await tester.pump();

      expect(find.text('Sin verificar'), findsOneWidget);
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

    testWidgets('calls verifyDoctor when verify button is pressed', (tester) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());
      addTearDown(() => tester.view.resetDevicePixelRatio());

      when(() => mockCubit.verifyDoctor(any())).thenAnswer((_) async {});
      
      await tester.pumpWidget(createWidgetUnderTest(unverifiedDoctor));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('VERIFICAR LICENCIA AHORA'));
      await tester.tap(find.text('VERIFICAR LICENCIA AHORA'));
      await tester.pump();

      verify(() => mockCubit.verifyDoctor(unverifiedDoctor)).called(1);
    });
  });
}
