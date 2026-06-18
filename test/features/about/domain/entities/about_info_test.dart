import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/about/domain/entities/about_info.dart';

void main() {
  group('BlogPost', () {
    test('supports value equality', () {
      expect(
        const BlogPost(
          title: 'Title',
          content: 'Content',
          date: '2024-05-10',
          category: 'Category',
        ),
        const BlogPost(
          title: 'Title',
          content: 'Content',
          date: '2024-05-10',
          category: 'Category',
        ),
      );
    });

    test('props are correct', () {
      const post = BlogPost(
        title: 'Title',
        content: 'Content',
        date: '2024-05-10',
        category: 'Category',
      );
      expect(post.props, ['Title', 'Content', '2024-05-10', 'Category']);
    });
  });

  group('AboutInfo', () {
    test('supports value equality', () {
      expect(
        const AboutInfo(
          blogPosts: [],
          missionStatement: 'Mission',
          values: ['Value'],
          activities: ['Activity'],
        ),
        const AboutInfo(
          blogPosts: [],
          missionStatement: 'Mission',
          values: ['Value'],
          activities: ['Activity'],
        ),
      );
    });

    test('props are correct', () {
      const info = AboutInfo(
        blogPosts: [],
        missionStatement: 'Mission',
        values: ['Value'],
        activities: ['Activity'],
      );
      expect(info.props, [[], 'Mission', ['Value'], ['Activity']]);
    });
  });
}
