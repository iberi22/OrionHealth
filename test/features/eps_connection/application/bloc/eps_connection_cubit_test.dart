import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/eps_connection/application/bloc/eps_connection_cubit.dart';
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
  late EpsConnectionCubit cubit;
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

    // Stub initial load call in constructor
    when(() => mockGetConnections()).thenAnswer((_) async => []);

    cubit = EpsConnectionCubit(
      mockGetConnections,
      mockConnectProvider,
      mockDisconnectProvider,
    );
  });

  tearDown(() {
    cubit.close();
  });

  group('EpsConnectionCubit', () {
    test('initial state is EpsConnectionLoaded after constructor load', () async {
      // Since it calls loadConnections in constructor
      await Future.delayed(Duration.zero);
      expect(cubit.state, const EpsConnectionLoaded([]));
    });

    test('loadConnections emits [Loading, Loaded] on success', () async {
      when(() => mockGetConnections()).thenAnswer((_) async => []);

      final expected = [
        const EpsConnectionLoading(),
        const EpsConnectionLoaded([]),
      ];

      expectLater(cubit.stream, emitsInOrder(expected));
      await cubit.loadConnections();
    });

    test('connect calls usecase and reloads', () async {
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

      await cubit.connect(provider);

      verify(() => mockConnectProvider(provider)).called(1);
      expect(cubit.state, const EpsConnectionLoaded([]));
    });

    test('disconnect calls usecase and reloads', () async {
      when(() => mockDisconnectProvider(any())).thenAnswer((_) async => {});
      when(() => mockGetConnections()).thenAnswer((_) async => []);

      await cubit.disconnect('123');

      verify(() => mockDisconnectProvider('123')).called(1);
      expect(cubit.state, const EpsConnectionLoaded([]));
    });
  });
}
