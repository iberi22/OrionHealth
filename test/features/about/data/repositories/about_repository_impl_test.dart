import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/about/data/datasources/about_local_datasource.dart';
import 'package:orionhealth_health/features/about/data/repositories/about_repository_impl.dart';
import 'package:orionhealth_health/features/about/domain/entities/about_info.dart';

class MockAboutLocalDataSource extends Mock implements AboutLocalDataSource {}

void main() {
  group('AboutRepositoryImpl (Data)', () {
    late AboutRepositoryImpl repository;
    late MockAboutLocalDataSource mockDataSource;

    final mockData = {
      'missionStatement': 'Test Mission',
      'values': ['Value 1', 'Value 2'],
      'activities': ['Activity 1'],
      'blogPosts': [
        {
          'title': 'Post 1',
          'content': 'Content 1',
          'date': '2024-01-01',
          'category': 'Cat 1'
        }
      ]
    };

    setUp(() {
      mockDataSource = MockAboutLocalDataSource();
      repository = AboutRepositoryImpl(mockDataSource);
    });

    test('getAboutInfo returns AboutInfo from datasource', () async {
      when(() => mockDataSource.getStaticAboutData()).thenReturn(mockData);

      final result = await repository.getAboutInfo();

      expect(result, isA<AboutInfo>());
      expect(result.missionStatement, 'Test Mission');
      expect(result.values, contains('Value 1'));
      expect(result.blogPosts.first.title, 'Post 1');
      verify(() => mockDataSource.getStaticAboutData()).called(1);
    });
  });
}
