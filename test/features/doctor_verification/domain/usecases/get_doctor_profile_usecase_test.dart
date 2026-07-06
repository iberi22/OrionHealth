import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/doctor_verification/domain/entities/doctor_profile.dart';
import 'package:orionhealth_health/features/doctor_verification/domain/repositories/doctor_profile_repository.dart';
import 'package:orionhealth_health/features/doctor_verification/domain/usecases/get_doctor_profile_usecase.dart';

class MockDoctorProfileRepository extends Mock
    implements DoctorProfileRepository {}

void main() {
  late MockDoctorProfileRepository mockRepository;
  late GetDoctorProfileUseCase useCase;

  setUp(() {
    mockRepository = MockDoctorProfileRepository();
    useCase = GetDoctorProfileUseCase(mockRepository);
  });

  const tId = '1';
  final tDoctorProfile = DoctorProfile(
    id: tId,
    fullName: 'Dr. Smith',
    specialty: 'Cardiology',
    licenseNumber: '12345',
    verified: true,
    countryCode: 'CO',
    createdAt: DateTime(2025, 1, 1),
    updatedAt: DateTime(2025, 1, 1),
  );

  test('should get doctor profile by id from the repository', () async {
    // arrange
    when(() => mockRepository.getDoctorProfile(any()))
        .thenAnswer((_) async => tDoctorProfile);

    // act
    final result = await useCase(tId);

    // assert
    expect(result, tDoctorProfile);
    verify(() => mockRepository.getDoctorProfile(tId)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
