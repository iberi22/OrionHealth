import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:orionhealth_health/core/di/injection.dart' as di;
import 'package:orionhealth_health/features/eps_connection/presentation/pages/eps_connection_page.dart';
import 'package:orionhealth_health/features/eps_connection/domain/repositories/oauth_repository.dart';
import 'package:orionhealth_health/features/eps_connection/domain/entities/eps_provider.dart';
import 'package:orionhealth_health/features/eps_connection/domain/entities/oauth_token.dart';
import 'package:orionhealth_health/features/user_profile/domain/repositories/user_profile_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:orionhealth_health/l10n/app_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'utils/video_recorder.dart';

class MockOAuthRepository extends Mock implements OAuthRepository {}
class MockUserProfileRepository extends Mock implements UserProfileRepository {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockOAuthRepository mockOauthRepo;
  late MockUserProfileRepository mockProfileRepo;

  setUpAll(() async {
    await di.configureDependencies();
    await initializeDateFormatting('es', null);
  });

  setUp(() {
    di.getIt.allowReassignment = true;
    mockOauthRepo = MockOAuthRepository();
    mockProfileRepo = MockUserProfileRepository();

    di.getIt.registerSingleton<OAuthRepository>(mockOauthRepo);
    di.getIt.registerSingleton<UserProfileRepository>(mockProfileRepo);
  });

  tearDown(() {
    di.getIt.unregister<OAuthRepository>();
    di.getIt.unregister<UserProfileRepository>();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: const EpsConnectionPage(),
      theme: ThemeData.dark(),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('es'),
    );
  }

  group('EPS Connection Flow - True E2E Tests', () {
    testWidgets('E2E: List and Disconnect Connections', (WidgetTester tester) async {
      final provider = const EPSProvider(
        id: '1',
        name: 'Sura',
        discoveryUrl: 'https://sura.example.com/.well-known/openid-configuration',
        clientId: 'test-client',
        redirectUrl: 'orionhealth://callback',
        scopes: ['openid', 'fhirUser', 'patient/*.read'],
        type: EPSProviderType.fhir,
      );

      final token = const OAuthToken(accessToken: 'test-token');

      // Setup mock repository responses
      when(() => mockOauthRepo.getConnectedProviders()).thenAnswer((_) async => ['1']);
      when(() => mockOauthRepo.getToken('1')).thenAnswer((_) async => token);
      when(() => mockOauthRepo.getProviderDetails('1')).thenAnswer((_) async => provider);
      when(() => mockOauthRepo.getPatientId('1')).thenAnswer((_) async => 'patient-001');

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'eps', '01_list');

      expect(find.text('Sura'), findsOneWidget);
      expect(find.textContaining('patient-001'), findsOneWidget);

      // TEST DISCONNECT
      when(() => mockOauthRepo.logout('1')).thenAnswer((_) async {});
      when(() => mockProfileRepo.getUserProfile()).thenAnswer((_) async => null);
      // After logout, it will reload, so mock an empty list
      when(() => mockOauthRepo.getConnectedProviders()).thenAnswer((_) async => []);

      await tester.tap(find.byIcon(Icons.link_off));
      // Cubit will call disconnect, then loadConnections
      await tester.pumpAndSettle();

      verify(() => mockOauthRepo.logout('1')).called(1);
      expect(find.text('No EPS providers connected'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'eps', '02_after_disconnect');
    });

    testWidgets('E2E: Empty State', (WidgetTester tester) async {
      when(() => mockOauthRepo.getConnectedProviders()).thenAnswer((_) async => []);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'eps', '03_empty');

      expect(find.text('No EPS providers connected'), findsOneWidget);
    });

    testWidgets('E2E: Error Handling', (WidgetTester tester) async {
      when(() => mockOauthRepo.getConnectedProviders()).thenThrow(Exception('Error de red'));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'eps', '04_error');

      expect(find.textContaining('Error de red'), findsOneWidget);
    });

    testWidgets('E2E: QR Scanner Button', (WidgetTester tester) async {
      when(() => mockOauthRepo.getConnectedProviders()).thenAnswer((_) async => []);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.qr_code_scanner));
      await tester.pump(); // Start snackbar animation

      expect(find.text('QR scanner coming soon'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'eps', '05_qr_scanner_snackbar');
    });
  });
}
