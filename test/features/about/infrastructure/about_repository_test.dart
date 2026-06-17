import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/about/infrastructure/repositories/about_repository_impl.dart';
import 'package:orionhealth_health/features/about/domain/entities/about_info.dart';

void main() {
  group('AboutRepositoryImpl', () {
    late AboutRepositoryImpl repository;

    setUp(() {
      repository = AboutRepositoryImpl();
    });

    test('getAboutInfo returns AboutInfo with static data', () async {
      final result = await repository.getAboutInfo();

      expect(result, isA<AboutInfo>());
      expect(result.missionStatement, contains('OrionHealth nace con la visión'));
      expect(result.blogPosts, isNotEmpty);
      expect(result.values, isNotEmpty);
      expect(result.activities, isNotEmpty);
    });

    test('getAboutInfo returns correct number of blog posts', () async {
      final result = await repository.getAboutInfo();
      expect(result.blogPosts.length, 4);
    });

    test('blog posts have required fields', () async {
      final result = await repository.getAboutInfo();
      final firstPost = result.blogPosts.first;

      expect(firstPost.title, isNotEmpty);
      expect(firstPost.content, isNotEmpty);
      expect(firstPost.date, isNotEmpty);
      expect(firstPost.category, isNotEmpty);
    });
  });
}
