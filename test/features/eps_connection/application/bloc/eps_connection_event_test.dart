import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/eps_connection/application/bloc/eps_connection_event.dart';
import 'package:orionhealth_health/features/eps_connection/domain/entities/eps_provider.dart';

void main() {
  group('EpsConnectionEvent', () {
    test('LoadConnections supports value equality', () {
      expect(const LoadConnections(), const LoadConnections());
    });

    test('ConnectProvider supports value equality', () {
      final provider = EPSProvider(
        id: '1',
        name: 'Test',
        discoveryUrl: '',
        clientId: '',
        redirectUrl: '',
        scopes: [],
      );
      expect(ConnectProvider(provider), ConnectProvider(provider));
    });

    test('DisconnectProvider supports value equality', () {
      expect(const DisconnectProvider('1'), const DisconnectProvider('1'));
    });
  });
}
