import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/eps_connection/application/bloc/eps_connection_state.dart';
import 'package:orionhealth_health/features/eps_connection/domain/entities/eps_provider.dart';

class MockEpsProvider extends EPSProvider {
  MockEpsProvider() : super(
    id: 'mock-id',
    name: 'Mock EPS',
    discoveryUrl: 'https://mock.eps.com',
    clientId: '',
    redirectUrl: '',
    scopes: const [],
  );
}

void main() {
  group('EpsConnectionState', () {
    test('EpsConnectionCatalog supports value equality', () {
      expect(
        const EpsConnectionCatalog(availableProviders: []),
        const EpsConnectionCatalog(availableProviders: []),
      );
    });

    test('EpsConnectionCatalog has correct defaults', () {
      const state = EpsConnectionCatalog(availableProviders: []);
      expect(state.availableProviders, isEmpty);
      expect(state.connections, isEmpty);
      expect(state.connectedProviderIds, isEmpty);
    });

    test('EpsConnectionLoading supports value equality', () {
      expect(const EpsConnectionLoading(), const EpsConnectionLoading());
    });

    test('EpsConnectionLoaded supports value equality', () {
      expect(const EpsConnectionLoaded([]), const EpsConnectionLoaded([]));
    });

    test('EpsConnectionError supports value equality', () {
      expect(const EpsConnectionError('msg'), const EpsConnectionError('msg'));
    });

    test('EpsConnectionPortalConnected supports value equality', () {
      final provider = MockEpsProvider();
      expect(
        EpsConnectionPortalConnected(provider: provider, patientId: '123'),
        EpsConnectionPortalConnected(provider: provider, patientId: '123'),
      );
    });
  });
}
