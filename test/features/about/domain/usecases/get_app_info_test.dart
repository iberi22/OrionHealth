import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/about/domain/entities/about_info.dart';
import 'package:orionhealth_health/features/about/domain/repositories/i_about_repository.dart';
import 'package:orionhealth_health/features/about/domain/usecases/get_app_info.dart';

class MockAboutRepository extends Mock implements IAboutRepository {}

void main() {
  late GetAppInfo usecase;
  late MockAboutRepository mockRepository;

  setUp(() {
    mockRepository = MockAboutRepository();
    usecase = GetAppInfo(mockRepository);
  });

  const tAboutInfo = AboutInfo(
    blogPosts: [],
    missionStatement: 'Test Mission',
    values: ['Value 1'],
    activities: ['Activity 1'],
  );

  test(
    'should get about info from the repository',
    () async {
      // arrange
      when(() => mockRepository.getAboutInfo())
          .thenAnswer((_) async => tAboutInfo);

      // act
      final result = await usecase.execute();

      // assert
      expect(result, tAboutInfo);
      verify(() => mockRepository.getAboutInfo());
      verifyNoMoreInteractions(mockRepository);
    },
  );
}
