import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/doctor_verification/application/doctor_verification_cubit.dart';
import 'package:orionhealth_health/features/doctor_verification/application/doctor_verification_state.dart';
import 'package:orionhealth_health/features/doctor_verification/presentation/pages/doctor_list_page.dart';
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

  setUpAll(() {
    getIt.reset();
    mockCubit = MockDoctorVerificationCubit();
    getIt.registerSingleton<DoctorVerificationCubit>(mockCubit);
  });

  setUp(() {
    reset(mockCubit);
    when(() => mockCubit.loadDoctors()).thenAnswer((_) async {});
  });

  Widget createWidgetUnderTest() {
    return const MaterialApp(
      home: DoctorListPage(),
    );
  }

  testWidgets('renders loading state', (tester) async {
    when(() => mockCubit.state).thenReturn(DoctorVerificationLoading());
    when(() => mockCubit.loadDoctors()).thenAnswer((_) async {});

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('renders empty state', (tester) async {
    when(() => mockCubit.state).thenReturn(const DoctorVerificationLoaded(doctors: [], averageRatings: {}));
    when(() => mockCubit.loadDoctors()).thenAnswer((_) async {});

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('No se encontraron médicos.'), findsOneWidget);
  });

  testWidgets('renders error state', (tester) async {
    when(() => mockCubit.state).thenReturn(const DoctorVerificationError('Failed to load'));
    when(() => mockCubit.loadDoctors()).thenAnswer((_) async {});

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('Failed to load'), findsOneWidget);
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

    when(() => mockCubit.state).thenReturn(DoctorVerificationLoaded(
      doctors: [doctor],
      averageRatings: {'1': 4.5},
    ));
    when(() => mockCubit.loadDoctors()).thenAnswer((_) async {});

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('Dr. Smith'), findsOneWidget);
    expect(find.text('Cardiology'), findsOneWidget);
    expect(find.text('Verificado'), findsOneWidget);
    expect(find.text('4.5'), findsOneWidget);
  });
}
