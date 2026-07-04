import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/about/infrastructure/datasources/about_local_datasource.dart';
import 'package:orionhealth_health/features/about/infrastructure/repositories/about_repository_impl.dart';

class MockAboutLocalDataSource extends Mock implements AboutLocalDataSource {}

void main() {
  late AboutRepositoryImpl repository;
  late MockAboutLocalDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockAboutLocalDataSource();
    repository = AboutRepositoryImpl(mockDataSource);
  });

  test('getAboutInfo throws when data source throws', () async {
    when(() => mockDataSource.getStaticAboutData()).thenThrow(Exception('DataSource error'));

    expect(() => repository.getAboutInfo(), throwsA(isA<Exception>()));
  });

  test('getAboutInfo throws when data is malformed', () async {
    when(() => mockDataSource.getStaticAboutData()).thenReturn({
      'missionStatement': 'Mission',
      'values': 'Not a list', // Should be a list
      'activities': [],
      'blogPosts': [],
    });

    expect(() => repository.getAboutInfo(), throwsA(isA<TypeError>()));
  });
}
