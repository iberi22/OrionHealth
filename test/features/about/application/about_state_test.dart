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
        name: 'OrionHealth',
        version: '1.0.0',
        description: 'Health app',
      );

      test('supports value equality', () {
        expect(AboutLoaded(info: info), equals(AboutLoaded(info: info)));
      });

      test('props are correct', () {
        expect(AboutLoaded(info: info).props, [info]);
      });

      test('different info are not equal', () {
        final otherInfo = const AboutInfo(
          name: 'Different',
          version: '2.0.0',
          description: 'Other',
        );
        expect(
          AboutLoaded(info: info),
          isNot(equals(AboutLoaded(info: otherInfo))),
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
