import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/about/domain/entities/about_info.dart';
import 'package:orionhealth_health/features/about/domain/repositories/i_about_repository.dart';
import 'package:orionhealth_health/features/about/domain/usecases/get_about_info_usecase.dart';

class MockIAboutRepository extends Mock implements IAboutRepository {}

void main() {
  late MockIAboutRepository mockRepository;
  late GetAboutInfoUseCase useCase;

  setUp(() {
    mockRepository = MockIAboutRepository();
    useCase = GetAboutInfoUseCase(mockRepository);
  });

  const tAboutInfo = AboutInfo(
    blogPosts: [],
    missionStatement: 'Test Mission',
    values: ['Test Value'],
    activities: ['Test Activity'],
  );

  test('should get about info from the repository', () async {
    // arrange
    when(() => mockRepository.getAboutInfo())
        .thenAnswer((_) async => tAboutInfo);

    // act
    final result = await useCase();

    // assert
    expect(result, tAboutInfo);
    verify(() => mockRepository.getAboutInfo()).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should throw an exception when repository fails', () async {
    // arrange
    when(() => mockRepository.getAboutInfo())
        .thenThrow(Exception('Repository Error'));

    // act
    final call = useCase();

    // assert
    expect(() => call, throwsA(isA<Exception>()));
    verify(() => mockRepository.getAboutInfo()).called(1);
  });
}
