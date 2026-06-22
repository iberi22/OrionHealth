import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/eps_connection/application/bloc/eps_connection_bloc.dart';
import 'package:orionhealth_health/features/eps_connection/application/bloc/eps_connection_event.dart';
import 'package:orionhealth_health/features/eps_connection/application/bloc/eps_connection_state.dart';
import 'package:orionhealth_health/features/eps_connection/domain/usecases/connect_provider_usecase.dart';
import 'package:orionhealth_health/features/eps_connection/domain/usecases/disconnect_provider_usecase.dart';
import 'package:orionhealth_health/features/eps_connection/domain/usecases/get_connections_usecase.dart';
import 'package:orionhealth_health/features/eps_connection/domain/entities/eps_provider.dart';

class MockGetConnectionsUseCase extends Mock implements GetConnectionsUseCase {}
class MockConnectProviderUseCase extends Mock implements ConnectProviderUseCase {}
class MockDisconnectProviderUseCase extends Mock implements DisconnectProviderUseCase {}
class FakeEPSProvider extends Fake implements EPSProvider {}

void main() {
  late EpsConnectionBloc bloc;
  late MockGetConnectionsUseCase mockGetConnections;
  late MockConnectProviderUseCase mockConnectProvider;
  late MockDisconnectProviderUseCase mockDisconnectProvider;

  setUpAll(() {
    registerFallbackValue(FakeEPSProvider());
  });

  setUp(() {
    mockGetConnections = MockGetConnectionsUseCase();
    mockConnectProvider = MockConnectProviderUseCase();
    mockDisconnectProvider = MockDisconnectProviderUseCase();
    bloc = EpsConnectionBloc(
      mockGetConnections,
      mockConnectProvider,
      mockDisconnectProvider,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('EpsConnectionBloc', () {
    test('initial state is EpsConnectionInitial', () {
      expect(bloc.state, const EpsConnectionInitial());
    });

    test('LoadConnections emits [Loading, Loaded] on success', () async {
      when(() => mockGetConnections()).thenAnswer((_) async => []);

      final expected = [
        const EpsConnectionLoading(),
        const EpsConnectionLoaded([]),
      ];

      expectLater(bloc.stream, emitsInOrder(expected));
      bloc.add(const LoadConnections());
    });

    test('LoadConnections emits [Loading, Error] on failure', () async {
      when(() => mockGetConnections()).thenThrow(Exception('failure'));

      final expected = [
        const EpsConnectionLoading(),
        isA<EpsConnectionError>(),
      ];

      expectLater(bloc.stream, emitsInOrder(expected));
      bloc.add(const LoadConnections());
    });

    test('ConnectProvider calls usecase and reloads', () async {
      final provider = EPSProvider(
        id: '1',
        name: 'Test',
        discoveryUrl: '',
        clientId: '',
        redirectUrl: '',
        scopes: [],
      );
      when(() => mockConnectProvider(any())).thenAnswer((_) async => {});
      when(() => mockGetConnections()).thenAnswer((_) async => []);

      bloc.add(ConnectProvider(provider));

      await expectLater(
        bloc.stream,
        emitsThrough(const EpsConnectionLoaded([])),
      );

      verify(() => mockConnectProvider(provider)).called(1);
    });
  });
}
