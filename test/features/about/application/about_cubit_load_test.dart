import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/about/application/about_cubit.dart';
import 'package:orionhealth_health/features/about/domain/entities/about_info.dart';
import 'package:orionhealth_health/features/about/domain/repositories/i_about_repository.dart';

class MockAboutRepository extends Mock implements IAboutRepository {}

void main() {
  late AboutCubit cubit;
  late MockAboutRepository mockRepository;

  const tAboutInfo = AboutInfo(
    blogPosts: [],
    missionStatement: 'Test Mission',
    values: ['Value 1'],
    activities: ['Activity 1'],
  );

  setUp(() {
    mockRepository = MockAboutRepository();
    cubit = AboutCubit(mockRepository);
  });

  tearDown(() {
    cubit.close();
  });

  test('loadAboutInfo calls repository', () async {
    when(() => mockRepository.getAboutInfo()).thenAnswer((_) async => tAboutInfo);

    await cubit.loadAboutInfo();

    verify(() => mockRepository.getAboutInfo()).called(1);
  });
}
