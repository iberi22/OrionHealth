import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/doctor_verification/application/bloc/doctor_verification_bloc.dart';
import 'package:orionhealth_health/features/doctor_verification/presentation/pages/doctor_list_page.dart';
import 'package:orionhealth_health/features/doctor_verification/domain/entities/doctor_profile.dart';
import 'package:orionhealth_health/features/doctor_verification/domain/repositories/doctor_profile_repository.dart';
import 'package:orionhealth_health/features/doctor_verification/domain/repositories/rating_repository.dart';
import 'package:orionhealth_health/features/doctor_verification/domain/services/license_verifier.dart';

class MockProfileRepo extends Mock implements DoctorProfileRepository {}
class MockRatingRepo extends Mock implements RatingRepository {}
class MockLicenseVerifier extends Mock implements LicenseVerifier {}

void main() {
  late MockProfileRepo mockProfileRepo;
  late MockRatingRepo mockRatingRepo;
  late MockLicenseVerifier mockLicenseVerifier;
  late DoctorVerificationBloc realBloc;

  setUp(() {
    mockProfileRepo = MockProfileRepo();
    mockRatingRepo = MockRatingRepo();
    mockLicenseVerifier = MockLicenseVerifier();

    realBloc = DoctorVerificationBloc(
      mockProfileRepo,
      mockRatingRepo,
      mockLicenseVerifier,
    );

    if (GetIt.I.isRegistered<DoctorVerificationBloc>()) {
      GetIt.I.unregister<DoctorVerificationBloc>();
    }
    GetIt.I.registerSingleton<DoctorVerificationBloc>(realBloc);
  });

  tearDown(() {
    if (GetIt.I.isRegistered<DoctorVerificationBloc>()) {
      GetIt.I.unregister<DoctorVerificationBloc>();
    }
  });

  Widget createWidgetUnderTest() {
    return const MaterialApp(
      home: DoctorListPage(),
    );
  }

  testWidgets('renders loading state', (tester) async {
    final completer = Completer<List<DoctorProfile>>();
    when(() => mockProfileRepo.getAllDoctorProfiles()).thenAnswer((_) => completer.future);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('renders empty state', (tester) async {
    when(() => mockProfileRepo.getAllDoctorProfiles()).thenAnswer((_) async => []);
    when(() => mockRatingRepo.getAverageForDoctor(any())).thenAnswer((_) async => 0.0);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('No se encontraron médicos.'), findsOneWidget);
  });

  testWidgets('renders error state', (tester) async {
    when(() => mockProfileRepo.getAllDoctorProfiles()).thenThrow(Exception('Network error'));

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.textContaining('Network error'), findsOneWidget);
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

    when(() => mockProfileRepo.getAllDoctorProfiles()).thenAnswer((_) async => [doctor]);
    when(() => mockRatingRepo.getAverageForDoctor('1')).thenAnswer((_) async => 4.5);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('Dr. Smith'), findsOneWidget);
    expect(find.text('Cardiology'), findsOneWidget);
  });
}
