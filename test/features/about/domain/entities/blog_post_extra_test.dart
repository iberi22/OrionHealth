import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/about/domain/entities/about_info.dart';

void main() {
  group('BlogPost Extra Tests', () {
    test('supports value equality', () {
      const post1 = BlogPost(
        title: 'A',
        content: 'B',
        date: 'C',
        category: 'D',
      );
      const post2 = BlogPost(
        title: 'A',
        content: 'B',
        date: 'C',
        category: 'D',
      );

      expect(post1, equals(post2));
    });

    test('different values are not equal', () {
      const post1 = BlogPost(
        title: 'A',
        content: 'B',
        date: 'C',
        category: 'D',
      );
      const post2 = BlogPost(
        title: 'Diff',
        content: 'B',
        date: 'C',
        category: 'D',
      );

      expect(post1, isNot(equals(post2)));
    });
  });
}
