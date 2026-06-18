import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/about/data/datasources/about_local_datasource.dart';

void main() {
  group('AboutLocalDataSource', () {
    late AboutLocalDataSource datasource;

    setUp(() {
      datasource = AboutLocalDataSource();
    });

    group('getStaticAboutData', () {
      test('returns mission statement', () {
        final data = datasource.getStaticAboutData();
        expect(data['missionStatement'], isA<String>());
        expect(data['missionStatement'].toString().length, greaterThan(0));
      });

      test('returns values list with 4 items', () {
        final data = datasource.getStaticAboutData();
        final values = data['values'] as List;
        expect(values.length, 4);
        expect(values[0], contains('persona'));
      });

      test('returns activities list with 4 items', () {
        final data = datasource.getStaticAboutData();
        final activities = data['activities'] as List;
        expect(activities.length, 4);
      });

      test('returns blogPosts list with 4 items', () {
        final data = datasource.getStaticAboutData();
        final posts = data['blogPosts'] as List;
        expect(posts.length, 4);
        expect(posts[0]['title'], contains('Avances'));
        expect(posts[0]['category'], equals('Ciencia'));
        expect(posts[0]['date'], isNotEmpty);
      });

      test('every blog post has required fields', () {
        final data = datasource.getStaticAboutData();
        final posts = data['blogPosts'] as List;
        for (final post in posts) {
          expect(post['title'], isA<String>());
          expect(post['content'], isA<String>());
          expect(post['date'], isA<String>());
          expect(post['category'], isA<String>());
        }
      });

      test('value at index 1 mentions privacidad', () {
        final data = datasource.getStaticAboutData();
        final values = data['values'] as List;
        expect(values[1].toString().toLowerCase(), contains('privacidad'));
      });

      test('values are non-empty strings', () {
        final data = datasource.getStaticAboutData();
        final values = data['values'] as List;
        for (final v in values) {
          expect(v.toString().length, greaterThan(10));
        }
      });
    });
  });
}
