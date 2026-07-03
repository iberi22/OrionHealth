import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/about/application/about_cubit.dart';
import 'package:orionhealth_health/features/about/domain/entities/about_info.dart';
import 'package:orionhealth_health/features/about/domain/usecases/check_updates.dart';
import 'package:orionhealth_health/features/about/domain/usecases/get_app_info.dart';

class MockGetAppInfo extends Mock implements GetAppInfo {}
class MockCheckUpdates extends Mock implements CheckUpdates {}

void main() {
  late AboutCubit cubit;
  late MockGetAppInfo mockGetAppInfo;
  late MockCheckUpdates mockCheckUpdates;

  const tAboutInfo = AboutInfo(
    blogPosts: [],
    missionStatement: 'Test Mission',
    values: ['Value 1'],
    activities: ['Activity 1'],
  );

  setUp(() {
    mockGetAppInfo = MockGetAppInfo();
    mockCheckUpdates = MockCheckUpdates();
    cubit = AboutCubit(mockGetAppInfo, mockCheckUpdates);
  });

  tearDown(() {
    cubit.close();
  });

  test('initial state is AboutInitial', () {
    expect(cubit.state, const AboutInitial());
  });

  group('loadAboutInfo', () {
    test(
      'emits [AboutLoading, AboutLoaded] when usecase returns data',
      () async {
        when(
          () => mockGetAppInfo.execute(),
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
      'emits [AboutLoading, AboutError] when usecase throws error',
      () async {
        const errorMessage = 'Exception: Error fetching data';
        when(
          () => mockGetAppInfo.execute(),
        ).thenThrow(Exception('Error fetching data'));

        final expectedStates = [
          const AboutLoading(),
          const AboutError(errorMessage),
        ];

        expectLater(cubit.stream, emitsInOrder(expectedStates));

        await cubit.loadAboutInfo();
      },
    );
   group('checkForUpdates', () {
    test('returns true when usecase returns true', () async {
      when(() => mockCheckUpdates.execute()).thenAnswer((_) async => true);

      final result = await cubit.checkForUpdates();

      expect(result, true);
    });

    test('returns false when usecase throws', () async {
      when(() => mockCheckUpdates.execute()).thenThrow(Exception());

      final result = await cubit.checkForUpdates();

      expect(result, false);
    });
  });
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
