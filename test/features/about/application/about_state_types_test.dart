import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/about/application/about_cubit.dart';
import 'package:orionhealth_health/features/about/domain/entities/about_info.dart';

void main() {
  group('AboutState Types', () {
    test('AboutInitial is a AboutState', () {
      expect(const AboutInitial(), isA<AboutState>());
    });

    test('AboutLoading is a AboutState', () {
      expect(const AboutLoading(), isA<AboutState>());
    });

    test('AboutLoaded is a AboutState', () {
      const info = AboutInfo(
        blogPosts: [],
        missionStatement: 'M',
        values: [],
        activities: [],
      );
      expect(const AboutLoaded(info), isA<AboutState>());
    });

    test('AboutError is a AboutState', () {
      expect(const AboutError('error'), isA<AboutState>());
    });
  });
}
