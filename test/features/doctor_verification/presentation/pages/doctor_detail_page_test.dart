import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    when(() => mockBloc.stream).thenAnswer(
      (_) => const Stream.empty(),
    );
    when(() => mockBloc.state).thenReturn(const DoctorVerificationInitial());
    when(() => mockBloc.close()).thenAnswer((_) async {});

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
      home: BlocProvider<DoctorVerificationBloc>.value(
        value: mockBloc,
        child: DoctorDetailPage(doctor: doctor),
      ),
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

    testWidgets('calls VerifyDoctor event when verify button is pressed', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(unverifiedDoctor));
      await tester.pump();

      await tester.tap(find.text('VERIFICAR LICENCIA AHORA'));
      await tester.pump();

      verify(() => mockBloc.add(VerifyDoctor(unverifiedDoctor))).called(1);
    });
  });
}
