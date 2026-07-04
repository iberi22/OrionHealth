import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:orionhealth_health/features/eps_connection/presentation/pages/eps_connection_page.dart';
import 'package:orionhealth_health/features/eps_connection/application/bloc/eps_connection_cubit.dart';
import 'package:orionhealth_health/features/eps_connection/domain/repositories/oauth_repository.dart';
import 'package:orionhealth_health/features/eps_connection/domain/usecases/connect_provider_usecase.dart';
import 'package:orionhealth_health/features/eps_connection/domain/usecases/disconnect_provider_usecase.dart';
import 'package:orionhealth_health/features/eps_connection/domain/usecases/get_connections_usecase.dart';
import 'package:orionhealth_health/features/eps_connection/domain/entities/eps_provider.dart';
import 'package:orionhealth_health/features/eps_connection/domain/entities/oauth_token.dart';
import 'package:orionhealth_health/features/user_profile/domain/repositories/user_profile_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'utils/video_recorder.dart';

class MockOAuthRepository extends Mock implements OAuthRepository {}
class MockUserProfileRepository extends Mock implements UserProfileRepository {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockOAuthRepository mockOauthRepo;
  late MockUserProfileRepository mockProfileRepo;
  late EpsConnectionCubit cubit;

  setUp(() {
    mockOauthRepo = MockOAuthRepository();
    mockProfileRepo = MockUserProfileRepository();

    // Create real use cases with mocked repositories
    final getConnections = GetConnectionsUseCase(mockOauthRepo);
    final connectProvider = ConnectProviderUseCase(mockOauthRepo, mockProfileRepo);
    final disconnectProvider = DisconnectProviderUseCase(mockOauthRepo, mockProfileRepo);

    // Initial stub for cubit constructor
    when(() => mockOauthRepo.getConnectedProviders()).thenAnswer((_) async => []);

    cubit = EpsConnectionCubit(
      getConnections,
      connectProvider,
      disconnectProvider,
    );

    GetIt.instance.registerSingleton<EpsConnectionCubit>(cubit);
  });

  tearDown(() {
    GetIt.instance.unregister<EpsConnectionCubit>();
    cubit.close();
  });

  group('EPS Connection Flow - E2E Tests (Integration Style)', () {
    testWidgets('E2E: List and Disconnect Connections', (WidgetTester tester) async {
      final provider = const EPSProvider(
        id: '1',
        name: 'Sura',
        discoveryUrl: 'https://sura.example.com/.well-known/openid-configuration',
        clientId: 'test-client',
        redirectUrl: 'orionhealth://callback',
        scopes: ['openid', 'fhirUser', 'patient/*.read'],
      );

      final token = const OAuthToken(accessToken: 'test-token');

      // Setup mock repository responses
      when(() => mockOauthRepo.getConnectedProviders()).thenAnswer((_) async => ['1']);
      when(() => mockOauthRepo.getToken('1')).thenAnswer((_) async => token);
      when(() => mockOauthRepo.getProviderDetails('1')).thenAnswer((_) async => provider);
      when(() => mockOauthRepo.getPatientId('1')).thenAnswer((_) async => 'patient-001');

      // Trigger load
      await cubit.loadConnections();

      await tester.pumpWidget(const MaterialApp(
        home: EpsConnectionPage(),
      ));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'eps', '01_list');

      expect(find.text('Sura'), findsOneWidget);
      expect(find.text('Patient ID: patient-001'), findsOneWidget);

      // TEST DISCONNECT
      when(() => mockOauthRepo.logout('1')).thenAnswer((_) async {});
      when(() => mockProfileRepo.getUserProfile()).thenAnswer((_) async => null);
      // After logout, it will reload, so mock an empty list
      when(() => mockOauthRepo.getConnectedProviders()).thenAnswer((_) async => []);

      await tester.tap(find.byIcon(Icons.link_off));
      await tester.pumpAndSettle();

      verify(() => mockOauthRepo.logout('1')).called(1);
      expect(find.text('No EPS providers connected'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'eps', '02_after_disconnect');
    });

    testWidgets('E2E: Empty State', (WidgetTester tester) async {
      when(() => mockOauthRepo.getConnectedProviders()).thenAnswer((_) async => []);
      await cubit.loadConnections();

      await tester.pumpWidget(const MaterialApp(
        home: EpsConnectionPage(),
      ));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'eps', '03_empty');

      expect(find.text('No EPS providers connected'), findsOneWidget);
    });

    testWidgets('E2E: Error Handling', (WidgetTester tester) async {
      when(() => mockOauthRepo.getConnectedProviders()).thenThrow(Exception('Network Error'));
      await cubit.loadConnections();

      await tester.pumpWidget(const MaterialApp(
        home: EpsConnectionPage(),
      ));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'eps', '04_error');

      expect(find.textContaining('Network Error'), findsOneWidget);
    });
  });
}
