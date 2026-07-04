import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/about/domain/entities/about_info.dart';

void main() {
  group('AboutInfo Data', () {
    test('supports empty blog posts', () {
      const info = AboutInfo(
        blogPosts: [],
        missionStatement: 'Mission',
        values: ['Value'],
        activities: ['Activity'],
      );
      expect(info.blogPosts, isEmpty);
    });

    test('supports multiple blog posts', () {
      const post1 = BlogPost(
        title: 'Title 1',
        content: 'Content 1',
        date: '2024-05-10',
        category: 'Category 1',
      );
      const post2 = BlogPost(
        title: 'Title 2',
        content: 'Content 2',
        date: '2024-05-11',
        category: 'Category 2',
      );
      const info = AboutInfo(
        blogPosts: [post1, post2],
        missionStatement: 'Mission',
        values: ['Value'],
        activities: ['Activity'],
      );
      expect(info.blogPosts.length, 2);
    });
  });
}
