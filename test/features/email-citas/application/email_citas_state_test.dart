import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/email-citas/application/email_citas_state.dart';

void main() {
  group('EmailCitasState', () {
    group('EmailCitasInitial', () {
      test('supports value equality', () {
        expect(const EmailCitasInitial(), equals(const EmailCitasInitial()));
      });
      test('props are empty', () {
        expect(const EmailCitasInitial().props, []);
      });
    });

    group('EmailCitasLoading', () {
      test('supports value equality', () {
        expect(const EmailCitasLoading(), equals(const EmailCitasLoading()));
      });
      test('props are empty', () {
        expect(const EmailCitasLoading().props, []);
      });
    });

    group('EmailCitasConnected', () {
      test('supports value equality', () {
        expect(
          const EmailCitasConnected(
            isGmailConnected: true,
            isOutlookConnected: false,
          ),
          equals(
            const EmailCitasConnected(
              isGmailConnected: true,
              isOutlookConnected: false,
            ),
          ),
        );
      });

      test('default values are false', () {
        expect(const EmailCitasConnected().isGmailConnected, false);
        expect(const EmailCitasConnected().isOutlookConnected, false);
      });

      test('props are correct', () {
        expect(
          const EmailCitasConnected(
            isGmailConnected: true,
            isOutlookConnected: true,
          ).props,
          [true, true],
        );
      });

      test('different connections are not equal', () {
        expect(
          const EmailCitasConnected(isGmailConnected: true),
          isNot(equals(const EmailCitasConnected())),
        );
      });

      test('copyWith updates gmail only', () {
        const state = EmailCitasConnected(
          isGmailConnected: true,
          isOutlookConnected: false,
        );
        final updated = state.copyWith(isOutlookConnected: true);
        expect(updated.isGmailConnected, true);
        expect(updated.isOutlookConnected, true);
      });

      test('copyWith with no args returns same state', () {
        const state = EmailCitasConnected(isGmailConnected: true);
        expect(state.copyWith(), equals(state));
      });
    });

    group('EmailCitasSyncSuccess', () {
      test('supports value equality', () {
        expect(
          const EmailCitasSyncSuccess(),
          equals(const EmailCitasSyncSuccess()),
        );
      });
      test('props are empty', () {
        expect(const EmailCitasSyncSuccess().props, []);
      });
    });

    group('EmailCitasError', () {
      test('supports value equality', () {
        expect(
          const EmailCitasError('err'),
          equals(const EmailCitasError('err')),
        );
      });
      test('different messages are not equal', () {
        expect(
          const EmailCitasError('err1'),
          isNot(equals(const EmailCitasError('err2'))),
        );
      });
      test('props contain message', () {
        expect(const EmailCitasError('err').props, ['err']);
      });
    });
  });
}
