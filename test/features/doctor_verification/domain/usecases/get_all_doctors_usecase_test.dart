import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/doctor_verification/domain/entities/doctor_profile.dart';
import 'package:orionhealth_health/features/doctor_verification/domain/repositories/doctor_profile_repository.dart';
import 'package:orionhealth_health/features/doctor_verification/domain/usecases/get_all_doctors_usecase.dart';

class MockDoctorProfileRepository extends Mock
    implements DoctorProfileRepository {}

void main() {
  late MockDoctorProfileRepository mockRepository;
  late GetAllDoctorsUseCase useCase;

  setUp(() {
    mockRepository = MockDoctorProfileRepository();
    useCase = GetAllDoctorsUseCase(mockRepository);
  });

  final tDoctorProfiles = [
    DoctorProfile(
      id: '1',
      fullName: 'Dr. Smith',
      specialty: 'Cardiology',
      licenseNumber: '12345',
      verified: true,
      countryCode: 'CO',
      createdAt: DateTime(2025, 1, 1),
      updatedAt: DateTime(2025, 1, 1),
    ),
  ];

  test('should get all doctor profiles from the repository', () async {
    // arrange
    when(() => mockRepository.getAllDoctorProfiles())
        .thenAnswer((_) async => tDoctorProfiles);

    // act
    final result = await useCase();

    // assert
    expect(result, tDoctorProfiles);
    verify(() => mockRepository.getAllDoctorProfiles()).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
