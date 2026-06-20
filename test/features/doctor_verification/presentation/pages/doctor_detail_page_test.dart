import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/doctor_verification/application/bloc/doctor_verification_bloc.dart';
import 'package:orionhealth_health/features/doctor_verification/presentation/pages/doctor_detail_page.dart';
import 'package:orionhealth_health/features/doctor_verification/domain/entities/doctor_profile.dart';

class MockDoctorVerificationBloc extends Mock implements DoctorVerificationBloc {}

void main() {
  late MockDoctorVerificationBloc mockBloc;
  late DoctorProfile verifiedDoctor;
  late DoctorProfile unverifiedDoctor;
  final tDate = DateTime(2023, 1, 1);

  setUp(() {
    mockBloc = MockDoctorVerificationBloc();
    when(() => mockBloc.state).thenReturn(const DoctorVerificationInitial());
    when(() => mockBloc.stream).thenAnswer(
      (_) => const Stream.empty(),
    );
    when(() => mockBloc.close()).thenAnswer((_) async {});

    if (GetIt.I.isRegistered<DoctorVerificationBloc>()) {
      GetIt.I.unregister<DoctorVerificationBloc>();
    }
    GetIt.I.registerSingleton<DoctorVerificationBloc>(mockBloc);

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
    if (GetIt.I.isRegistered<DoctorVerificationBloc>()) {
      GetIt.I.unregister<DoctorVerificationBloc>();
    }
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

      // There are two "Dr. Verified" texts: one in AppBar and one in Header.
      expect(find.text('Dr. Verified'), findsNWidgets(2));
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

    testWidgets('calls verifyDoctor when verify button is pressed', (tester) async {
      // Set a larger screen size to avoid hit test issues
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createWidgetUnderTest(unverifiedDoctor));
      await tester.pump();

      await tester.tap(find.text('VERIFICAR LICENCIA AHORA'));
      await tester.pump();

      verify(() => mockBloc.add(VerifyDoctor(unverifiedDoctor))).called(1);
    });
  });
}
