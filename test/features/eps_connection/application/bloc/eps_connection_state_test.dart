import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/eps_connection/application/bloc/eps_connection_state.dart';

void main() {
  group('EpsConnectionState', () {
    test('EpsConnectionInitial supports value equality', () {
      expect(const EpsConnectionInitial(), const EpsConnectionInitial());
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
  });
}
