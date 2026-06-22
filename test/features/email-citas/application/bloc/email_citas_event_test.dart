import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/email-citas/application/bloc/email_citas_event.dart';

void main() {
  group('EmailCitasEvent', () {
    test('ConnectGmail supports value equality', () {
      expect(const ConnectGmail(), const ConnectGmail());
    });

    test('ConnectOutlook supports value equality', () {
      expect(const ConnectOutlook(), const ConnectOutlook());
    });

    test('HandleOAuthRedirect supports value equality', () {
      final uri = Uri.parse('https://example.com');
      expect(HandleOAuthRedirect(uri), HandleOAuthRedirect(uri));
    });

    test('ManualSync supports value equality', () {
      expect(const ManualSync(), const ManualSync());
    });

    test('SyncAppointments supports value equality', () {
      expect(const SyncAppointments('code'), const SyncAppointments('code'));
    });
  });
}
