import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/doctor_verification/application/bloc/doctor_verification_bloc.dart';
import 'package:orionhealth_health/features/doctor_verification/presentation/pages/doctor_list_page.dart';
import 'package:orionhealth_health/features/doctor_verification/domain/entities/doctor_profile.dart';

class MockDoctorVerificationBloc extends Mock implements DoctorVerificationBloc {}

void main() {
  late MockDoctorVerificationBloc mockBloc;

  setUp(() {
    mockBloc = MockDoctorVerificationBloc();
    when(() => mockBloc.close()).thenAnswer((_) async {});
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<DoctorVerificationBloc>.value(
        value: mockBloc,
        child: const DoctorListPage(),
      ),
    );
  }

  testWidgets('renders loading state', (tester) async {
    when(() => mockBloc.state).thenReturn(const DoctorVerificationLoading());
    when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('renders empty state', (tester) async {
    when(() => mockBloc.state).thenReturn(const DoctorVerificationLoaded(doctors: [], averageRatings: {}));
    when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('No se encontraron médicos.'), findsOneWidget);
  });

  testWidgets('renders doctors list when loaded', (tester) async {
    final doctor = DoctorProfile(
      id: '1',
      fullName: 'Dr. Smith',
      specialty: 'Cardiology',
      countryCode: 'US',
      verified: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    when(() => mockBloc.state).thenReturn(DoctorVerificationLoaded(doctors: [doctor], averageRatings: {'1': 4.5}));
    when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('Dr. Smith'), findsOneWidget);
    expect(find.text('Cardiology'), findsOneWidget);
  });
}
