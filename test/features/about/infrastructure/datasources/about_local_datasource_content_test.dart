import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/about/infrastructure/datasources/about_local_datasource.dart';

void main() {
  group('AboutLocalDataSource Content', () {
    late AboutLocalDataSource dataSource;

    setUp(() {
      dataSource = AboutLocalDataSource();
    });

    test('getStaticAboutData contains expected keys', () {
      final data = dataSource.getStaticAboutData();
      expect(data.containsKey('missionStatement'), isTrue);
      expect(data.containsKey('values'), isTrue);
      expect(data.containsKey('activities'), isTrue);
      expect(data.containsKey('blogPosts'), isTrue);
    });

    test('getStaticAboutData returns non-empty content', () {
      final data = dataSource.getStaticAboutData();
      expect(data['missionStatement'], isNotEmpty);
      expect(data['values'], isNotEmpty);
      expect(data['activities'], isNotEmpty);
      expect(data['blogPosts'], isNotEmpty);
    });
  });
}
