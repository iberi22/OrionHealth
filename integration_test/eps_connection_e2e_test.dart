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
import 'utils/video_recorder.dart';

class MockOAuthRepository extends Mock implements OAuthRepository {}
class MockUserProfileRepository extends Mock implements UserProfileRepository {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockOAuthRepository mockOauthRepo;
  late MockUserProfileRepository mockProfileRepo;

  setUpAll(() async {
    await di.configureDependencies();
    di.getIt.allowReassignment = true;

    mockOauthRepo = MockOAuthRepository();
    mockProfileRepo = MockUserProfileRepository();

    di.getIt.registerSingleton<OAuthRepository>(mockOauthRepo);
    di.getIt.registerSingleton<UserProfileRepository>(mockProfileRepo);
  });

  group('EPS Connection Flow - E2E Tests', () {
    testWidgets('E2E: List and Disconnect Connections', (WidgetTester tester) async {
      // Setup mock data
      final provider = const EPSProvider(
        id: '1',
        name: 'Sura',
        discoveryUrl: 'https://sura.example.com/.well-known/openid-configuration',
        clientId: 'test-client',
        redirectUrl: 'orionhealth://callback',
        scopes: ['openid', 'fhirUser', 'patient/*.read'],
      );

      final token = const OAuthToken(accessToken: 'test-token');

      when(() => mockOauthRepo.getConnectedProviders()).thenAnswer((_) async => ['1']);
      when(() => mockOauthRepo.getToken('1')).thenAnswer((_) async => token);
      when(() => mockOauthRepo.getProviderDetails('1')).thenAnswer((_) async => provider);
      when(() => mockOauthRepo.getPatientId('1')).thenAnswer((_) async => 'patient-001');

      await tester.pumpWidget(
        MaterialApp(
          home: const EpsConnectionPage(),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
        ),
      );

      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'eps', '01_list');

      expect(find.text('Sura'), findsOneWidget);
      expect(find.text('Patient ID: patient-001'), findsOneWidget);

      // TEST DISCONNECT
      when(() => mockOauthRepo.logout('1')).thenAnswer((_) async {});
      when(() => mockOauthRepo.getConnectedProviders()).thenAnswer((_) async => []);

      await tester.tap(find.byIcon(Icons.link_off));
      await tester.pumpAndSettle();

      verify(() => mockOauthRepo.logout('1')).called(1);
      expect(find.text('No EPS providers connected'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'eps', '02_after_disconnect');
    });

    testWidgets('E2E: Empty State', (WidgetTester tester) async {
      when(() => mockOauthRepo.getConnectedProviders()).thenAnswer((_) async => []);

      await tester.pumpWidget(
        MaterialApp(
          home: const EpsConnectionPage(),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
        ),
      );
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'eps', '03_empty');

      expect(find.text('No EPS providers connected'), findsOneWidget);
    });

    testWidgets('E2E: Error Handling', (WidgetTester tester) async {
      when(() => mockOauthRepo.getConnectedProviders()).thenThrow(Exception('Network Error'));

      await tester.pumpWidget(
        MaterialApp(
          home: const EpsConnectionPage(),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
        ),
      );
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'eps', '04_error');

      expect(find.textContaining('Network Error'), findsOneWidget);
    });
  });
}
