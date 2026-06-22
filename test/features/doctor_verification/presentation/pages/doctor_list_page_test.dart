import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/doctor_verification/application/doctor_verification_cubit.dart';
import 'package:orionhealth_health/features/doctor_verification/application/doctor_verification_state.dart';
import 'package:orionhealth_health/features/doctor_verification/presentation/pages/doctor_list_page.dart';
import 'package:orionhealth_health/features/doctor_verification/domain/entities/doctor_profile.dart';
import 'package:get_it/get_it.dart';

class MockDoctorVerificationCubit extends Mock implements DoctorVerificationCubit {}

void main() {
  late MockDoctorVerificationCubit mockCubit;

  setUp(() {
    mockCubit = MockDoctorVerificationCubit();
    when(() => mockCubit.close()).thenAnswer((_) async {});
    if (!GetIt.I.isRegistered<DoctorVerificationCubit>()) {
      GetIt.I.registerLazySingleton<DoctorVerificationCubit>(() => mockCubit);
    }
  });

  tearDown(() {
    GetIt.I.unregister<DoctorVerificationCubit>();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<DoctorVerificationCubit>.value(
        value: mockCubit,
        child: const DoctorListPage(),
      ),
    );
  }

  testWidgets('renders loading state', (tester) async {
    when(() => mockCubit.state).thenReturn(const DoctorVerificationLoading());
    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockCubit.loadDoctors()).thenAnswer((_) async {});

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('renders empty state', (tester) async {
    when(() => mockCubit.state).thenReturn(const DoctorVerificationLoaded(doctors: [], averageRatings: {}));
    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockCubit.loadDoctors()).thenAnswer((_) async {});

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

    when(() => mockCubit.state).thenReturn(DoctorVerificationLoaded(doctors: [doctor], averageRatings: {'1': 4.5}));
    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockCubit.loadDoctors()).thenAnswer((_) async {});

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('Dr. Smith'), findsOneWidget);
    expect(find.text('Cardiology'), findsOneWidget);
  });
}
