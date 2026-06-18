import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/eps_connection/application/bloc/eps_connection_state.dart';
import 'package:orionhealth_health/features/eps_connection/domain/entities/eps_connection.dart';
import 'package:orionhealth_health/features/eps_connection/domain/entities/eps_provider.dart';
import 'package:orionhealth_health/features/eps_connection/domain/entities/oauth_token.dart';

void main() {
  group('EpsConnectionState', () {
    test('EpsConnectionInitial supports equality', () {
      const state = EpsConnectionInitial();
      expect(state, const EpsConnectionInitial());
      expect(state.props, isEmpty);
    });

    test('EpsConnectionLoading supports equality', () {
      const state = EpsConnectionLoading();
      expect(state, const EpsConnectionLoading());
      expect(state.props, isEmpty);
    });

    test('EpsConnectionLoaded supports equality', () {
      final conn = EPSConnection(
        provider: const EPSProvider(id: '1', name: 'N', discoveryUrl: 'D', clientId: 'C', redirectUrl: 'R', scopes: []),
        token: const OAuthToken(accessToken: 'A'),
        patientId: 'P',
        connectedAt: DateTime(2023),
      );
      final state = EpsConnectionLoaded([conn]);
      expect(state, EpsConnectionLoaded([conn]));
      expect(state.props, [[conn]]);
    });

    test('EpsConnectionError supports equality', () {
      const state = EpsConnectionError('error');
      expect(state, const EpsConnectionError('error'));
      expect(state.props, ['error']);
    });
  });
}
