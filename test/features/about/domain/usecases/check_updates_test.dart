import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/about/domain/repositories/i_about_repository.dart';
import 'package:orionhealth_health/features/about/domain/usecases/check_updates.dart';

class MockAboutRepository extends Mock implements IAboutRepository {}

void main() {
  late CheckUpdates usecase;
  late MockAboutRepository mockRepository;

  setUp(() {
    mockRepository = MockAboutRepository();
    usecase = CheckUpdates(mockRepository);
  });

  test(
    'should check for updates from the repository',
    () async {
      // arrange
      when(() => mockRepository.checkUpdates())
          .thenAnswer((_) async => true);

      // act
      final result = await usecase.execute();

      // assert
      expect(result, true);
      verify(() => mockRepository.checkUpdates());
      verifyNoMoreInteractions(mockRepository);
    },
  );
}
