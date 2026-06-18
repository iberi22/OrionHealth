import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/about/application/about_cubit.dart';
import 'package:orionhealth_health/features/about/domain/entities/about_info.dart';

void main() {
  group('AboutState', () {
    group('AboutInitial', () {
      test('supports value equality', () {
        expect(const AboutInitial(), equals(const AboutInitial()));
      });
      test('props are empty', () {
        expect(const AboutInitial().props, []);
      });
    });

    group('AboutLoading', () {
      test('supports value equality', () {
        expect(const AboutLoading(), equals(const AboutLoading()));
      });
      test('props are empty', () {
        expect(const AboutLoading().props, []);
      });
    });

    group('AboutLoaded', () {
      final info = const AboutInfo(
        blogPosts: [],
        missionStatement: 'Health app',
        values: ['Integrity', 'Care'],
        activities: ['Community outreach'],
      );

      test('supports value equality', () {
        expect(AboutLoaded(info), equals(AboutLoaded(info)));
      });

      test('props are correct', () {
        expect(AboutLoaded(info).props, [info]);
      });

      test('different info are not equal', () {
        final otherInfo = const AboutInfo(
          blogPosts: [],
          missionStatement: 'Different mission',
          values: ['Different values'],
          activities: ['Other'],
        );
        expect(
          AboutLoaded(info),
          isNot(equals(AboutLoaded(otherInfo))),
        );
      });
    });

    group('AboutError', () {
      test('supports value equality', () {
        expect(const AboutError('err'), equals(const AboutError('err')));
      });
      test('different messages are not equal', () {
        expect(
          const AboutError('err1'),
          isNot(equals(const AboutError('err2'))),
        );
      });
      test('props contain message', () {
        expect(const AboutError('err').props, ['err']);
      });
    });
  });
}
