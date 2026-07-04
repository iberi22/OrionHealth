import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/about/application/about_cubit.dart';
import 'package:orionhealth_health/features/about/domain/repositories/i_about_repository.dart';

class MockAboutRepository extends Mock implements IAboutRepository {}

void main() {
  late AboutCubit cubit;
  late MockAboutRepository mockRepository;

  setUp(() {
    mockRepository = MockAboutRepository();
    cubit = AboutCubit(mockRepository);
  });

  tearDown(() {
    cubit.close();
  });

  test('loadAboutInfo emits AboutError with message when repository throws', () async {
    const errorMsg = 'Failed to load';
    when(() => mockRepository.getAboutInfo()).thenThrow(errorMsg);

    final expectedStates = [
      const AboutLoading(),
      const AboutError(errorMsg),
    ];

    expectLater(cubit.stream, emitsInOrder(expectedStates));

    await cubit.loadAboutInfo();
  });
}
