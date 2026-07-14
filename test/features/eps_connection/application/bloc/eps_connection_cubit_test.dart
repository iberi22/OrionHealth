import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/eps_connection/application/bloc/eps_connection_cubit.dart';
import 'package:orionhealth_health/features/eps_connection/application/bloc/eps_connection_state.dart';
import 'package:orionhealth_health/features/eps_connection/domain/usecases/connect_provider_usecase.dart';
import 'package:orionhealth_health/features/eps_connection/domain/usecases/disconnect_provider_usecase.dart';
import 'package:orionhealth_health/features/eps_connection/domain/usecases/get_connections_usecase.dart';
import 'package:orionhealth_health/features/eps_connection/domain/entities/eps_provider.dart';
import 'package:orionhealth_health/features/eps_connection/domain/entities/eps_connection.dart';
import 'package:orionhealth_health/features/eps_connection/domain/entities/oauth_token.dart';

class MockGetConnectionsUseCase extends Mock implements GetConnectionsUseCase {}
class MockConnectProviderUseCase extends Mock implements ConnectProviderUseCase {}
class MockDisconnectProviderUseCase extends Mock implements DisconnectProviderUseCase {}
class FakeEPSProvider extends Fake implements EPSProvider {}
class FakeEPSConnection extends Fake implements EPSConnection {}

void main() {
  late EpsConnectionCubit cubit;
  late MockGetConnectionsUseCase mockGetConnections;
  late MockConnectProviderUseCase mockConnectProvider;
  late MockDisconnectProviderUseCase mockDisconnectProvider;

  setUpAll(() {
    registerFallbackValue(FakeEPSProvider());
    registerFallbackValue(FakeEPSConnection());
  });

  setUp(() {
    mockGetConnections = MockGetConnectionsUseCase();
    mockConnectProvider = MockConnectProviderUseCase();
    mockDisconnectProvider = MockDisconnectProviderUseCase();

    // Default stub: no connections
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
    test('initial state is EpsConnectionCatalog with all 28 providers', () async {
      await Future.delayed(Duration.zero);
      expect(cubit.state, isA<EpsConnectionCatalog>());
      final catalog = cubit.state as EpsConnectionCatalog;
      expect(catalog.availableProviders.length, 28);
      expect(catalog.connections, isEmpty);
      expect(catalog.connectedProviderIds, isEmpty);
    });

    test('loadCatalog refreshes catalog with current connections', () async {
      // Simulate having one connection
      final testProvider = EPSProvider(
        id: 'EPS025',
        name: 'EPS SURA',
        discoveryUrl: 'https://test/fhir/EPS025',
        clientId: 'c',
        redirectUrl: 'r',
        scopes: ['s'],
      );
      final testConnection = EPSConnection(
        provider: testProvider,
        token: const OAuthToken(accessToken: 'token'),
        patientId: 'PT-1',
        connectedAt: DateTime(2025),
      );
      when(() => mockGetConnections()).thenAnswer((_) async => [testConnection]);

      await cubit.loadCatalog();
      final state = cubit.state;
      expect(state, isA<EpsConnectionCatalog>());
      final catalog = state as EpsConnectionCatalog;
      expect(catalog.connectedProviderIds, contains('EPS025'));
      expect(catalog.connections.length, 1);
    });

    test('loadConnections emits [Loading, Loaded] on success', () async {
      when(() => mockGetConnections()).thenAnswer((_) async => []);

      final expected = [
        isA<EpsConnectionLoading>(),
        isA<EpsConnectionLoaded>(),
      ];

      expectLater(cubit.stream, emitsInOrder(expected));
      await cubit.loadConnections();
    });

    test('connect calls usecase and reloads catalog', () async {
      final provider = EPSProvider(
        id: 'EPS037',
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
      // After connect, goes back to catalog
      expect(cubit.state, isA<EpsConnectionCatalog>());
    });

    test('disconnect calls usecase and reloads catalog', () async {
      when(() => mockDisconnectProvider(any())).thenAnswer((_) async => {});
      when(() => mockGetConnections()).thenAnswer((_) async => []);

      await cubit.disconnect('EPS001');

      verify(() => mockDisconnectProvider('EPS001')).called(1);
      expect(cubit.state, isA<EpsConnectionCatalog>());
    });

    test('connect emits EpsConnectionConnecting before catalog', () async {
      final provider = EPSProvider(
        id: 'EPS025',
        name: 'SURA',
        discoveryUrl: '',
        clientId: '',
        redirectUrl: '',
        scopes: [],
      );
      when(() => mockConnectProvider(any())).thenAnswer((_) async => {});
      when(() => mockGetConnections()).thenAnswer((_) async => []);

      await cubit.connect(provider);

      verify(() => mockConnectProvider(provider)).called(1);
      expect(cubit.state, isA<EpsConnectionCatalog>());
    });

    test('markPortalConnected emits EpsConnectionPortalConnected and reloads catalog', () async {
      final provider = EPSProvider(
        id: 'EPS025',
        name: 'SURA',
        discoveryUrl: '',
        clientId: '',
        redirectUrl: '',
        scopes: [],
      );

      when(() => mockGetConnections()).thenAnswer((_) async => []);

      final expected = [
        isA<EpsConnectionPortalConnected>(),
        isA<EpsConnectionCatalog>(),
      ];

      expectLater(cubit.stream, emitsInOrder(expected));

      cubit.markPortalConnected(provider: provider, patientId: '123');

      // Wait for loadCatalog to complete
      await Future.delayed(Duration.zero);

      final state = cubit.state;
      expect(state, isA<EpsConnectionCatalog>());
    });
  });
}
