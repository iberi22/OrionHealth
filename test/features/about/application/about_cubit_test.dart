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

  test('initial state is AboutInitial', () {
    expect(cubit.state, const AboutInitial());
  });

  group('loadAboutInfo', () {
    test(
      'emits [AboutLoading, AboutLoaded] when repository returns data',
      () async {
        when(
          () => mockRepository.getAboutInfo(),
        ).thenAnswer((_) async => tAboutInfo);

        final expectedStates = [
          const AboutLoading(),
          const AboutLoaded(tAboutInfo),
        ];

        expectLater(cubit.stream, emitsInOrder(expectedStates));

        await cubit.loadAboutInfo();
      },
    );

    test(
      'emits [AboutLoading, AboutError] when repository throws error',
      () async {
        const errorMessage = 'Exception: Error fetching data';
        when(
          () => mockRepository.getAboutInfo(),
        ).thenThrow(Exception('Error fetching data'));

        final expectedStates = [
          const AboutLoading(),
          const AboutError(errorMessage),
        ];

        expectLater(cubit.stream, emitsInOrder(expectedStates));

        await cubit.loadAboutInfo();
      },
    );
  });

  group('AboutState Equatable', () {
    test('AboutLoaded supports value equality', () {
      expect(const AboutLoaded(tAboutInfo), const AboutLoaded(tAboutInfo));
    });

    test('AboutError supports value equality', () {
      expect(const AboutError('error'), const AboutError('error'));
    });

    test('AboutInitial supports value equality', () {
      expect(const AboutInitial(), const AboutInitial());
    });

    test('AboutLoading supports value equality', () {
      expect(const AboutLoading(), const AboutLoading());
    });
  });
}
