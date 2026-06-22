import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/about/infrastructure/repositories/about_repository_impl.dart';
import 'package:orionhealth_health/features/about/domain/entities/about_info.dart';

void main() {
  group('AboutRepositoryImpl (Infrastructure)', () {
    late AboutRepositoryImpl repository;

    setUp(() {
      repository = AboutRepositoryImpl();
    });

    test('getAboutInfo returns static data', () async {
      final result = await repository.getAboutInfo();

      expect(result, isA<AboutInfo>());
      expect(result.missionStatement, contains('Creemos que la salud'));
      expect(result.values, hasLength(4));
      expect(result.activities, hasLength(4));
      expect(result.blogPosts, hasLength(4));
    });

    test('blog posts have expected data', () async {
      final result = await repository.getAboutInfo();
      final firstPost = result.blogPosts.first;

      expect(firstPost.title, isNotEmpty);
      expect(firstPost.category, isNotEmpty);
      expect(firstPost.date, isNotEmpty);
      expect(firstPost.content, isNotEmpty);
    });
  });
}
