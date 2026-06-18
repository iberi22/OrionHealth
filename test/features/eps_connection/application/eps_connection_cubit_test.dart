import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/eps_connection/application/bloc/eps_connection_cubit.dart';
import 'package:orionhealth_health/features/eps_connection/application/bloc/eps_connection_state.dart';
import 'package:orionhealth_health/features/eps_connection/domain/entities/eps_connection.dart';
import 'package:orionhealth_health/features/eps_connection/domain/entities/eps_provider.dart';
import 'package:orionhealth_health/features/eps_connection/domain/entities/oauth_token.dart';
import 'package:orionhealth_health/features/eps_connection/domain/usecases/connect_provider_usecase.dart';
import 'package:orionhealth_health/features/eps_connection/domain/usecases/disconnect_provider_usecase.dart';
import 'package:orionhealth_health/features/eps_connection/domain/usecases/get_connections_usecase.dart';

class MockGetConnectionsUseCase extends Mock implements GetConnectionsUseCase {}
class MockConnectProviderUseCase extends Mock implements ConnectProviderUseCase {}
class MockDisconnectProviderUseCase extends Mock implements DisconnectProviderUseCase {}

void main() {
  late EpsConnectionCubit cubit;
  late MockGetConnectionsUseCase mockGetConnectionsUseCase;
  late MockConnectProviderUseCase mockConnectProviderUseCase;
  late MockDisconnectProviderUseCase mockDisconnectProviderUseCase;

  final testProvider = const EPSProvider(
    id: 'test_id',
    name: 'Test EPS',
    discoveryUrl: 'D',
    clientId: 'C',
    redirectUrl: 'R',
    scopes: ['S'],
  );

  final testConnection = EPSConnection(
    provider: testProvider,
    token: const OAuthToken(accessToken: 'token'),
    patientId: 'PT-123',
    connectedAt: DateTime.now(),
  );

  setUpAll(() {
    registerFallbackValue(testProvider);
  });

  setUp(() {
    mockGetConnectionsUseCase = MockGetConnectionsUseCase();
    mockConnectProviderUseCase = MockConnectProviderUseCase();
    mockDisconnectProviderUseCase = MockDisconnectProviderUseCase();

    when(() => mockGetConnectionsUseCase()).thenAnswer((_) async => []);
  });

  Future<void> buildCubit() async {
    cubit = EpsConnectionCubit(
      mockGetConnectionsUseCase,
      mockConnectProviderUseCase,
      mockDisconnectProviderUseCase,
    );
    await Future.delayed(Duration.zero);
  }

  group('EpsConnectionCubit', () {
    test('loadConnections emits Loaded state with connections', () async {
      when(() => mockGetConnectionsUseCase()).thenAnswer((_) async => [testConnection]);

      await buildCubit();

      expect(cubit.state, isA<EpsConnectionLoaded>());
      final state = cubit.state as EpsConnectionLoaded;
      expect(state.connections, [testConnection]);
    });

    test('loadConnections emits Error state on exception', () async {
      when(() => mockGetConnectionsUseCase()).thenThrow(Exception('Fail'));

      await buildCubit();

      expect(cubit.state, isA<EpsConnectionError>());
      expect((cubit.state as EpsConnectionError).message, contains('Fail'));
    });

    test('connect calls usecase and reloads', () async {
      when(() => mockConnectProviderUseCase(any())).thenAnswer((_) async => {});
      when(() => mockGetConnectionsUseCase()).thenAnswer((_) async => [testConnection]);

      await buildCubit();
      await cubit.connect(testProvider);

      verify(() => mockConnectProviderUseCase(testProvider)).called(1);
      expect(cubit.state, isA<EpsConnectionLoaded>());
    });

    test('connect emits Error state on exception', () async {
      when(() => mockConnectProviderUseCase(any())).thenThrow(Exception('Connect Fail'));

      await buildCubit();
      await cubit.connect(testProvider);

      expect(cubit.state, isA<EpsConnectionError>());
      expect((cubit.state as EpsConnectionError).message, contains('Connect Fail'));
    });

    test('disconnect calls usecase and reloads', () async {
      when(() => mockDisconnectProviderUseCase(any())).thenAnswer((_) async => {});
      when(() => mockGetConnectionsUseCase()).thenAnswer((_) async => []);

      await buildCubit();
      await cubit.disconnect('test_id');

      verify(() => mockDisconnectProviderUseCase('test_id')).called(1);
      expect(cubit.state, isA<EpsConnectionLoaded>());
    });

    test('disconnect emits Error state on exception', () async {
      when(() => mockDisconnectProviderUseCase(any())).thenThrow(Exception('Disconnect Fail'));

      await buildCubit();
      await cubit.disconnect('test_id');

      expect(cubit.state, isA<EpsConnectionError>());
      expect((cubit.state as EpsConnectionError).message, contains('Disconnect Fail'));
    });
  });
}
