import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:orionhealth_health/core/di/injection.dart' as di;
import 'package:orionhealth_health/features/about/presentation/pages/about_page.dart';
import 'package:orionhealth_health/features/user_profile/presentation/pages/user_profile_page.dart';
import 'package:orionhealth_health/features/user_profile/presentation/widgets/profile_info_tile.dart';
import 'package:isar/isar.dart';
import 'package:orionhealth_health/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:orionhealth_health/main.dart' as app;
import 'utils/pump_until.dart';
import 'utils/video_recorder.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await di.configureDependencies();
    await initializeDateFormatting('es', null);
  });

  group('About Flow - True E2E Tests', () {
    testWidgets(
      'E2E: Navigation to About Page from Profile and Real Data Verification',
      (WidgetTester tester) async {
        Widget buildApp() {
          return MaterialApp(
            home: const UserProfilePage(),
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

        // Start from User Profile to test navigation
        await tester.pumpWidget(buildApp());

        final l10n = await AppLocalizations.delegate.load(const Locale('es'));

        // Navigate to About OrionHealth
        // Use pumpUntilFound to wait for the UI to be ready
        final tile = find.widgetWithText(
          ProfileInfoTile,
          l10n.aboutOrionHealth,
        );
        await tester.ensureVisible(tile);
        await tester.pumpAndSettle();
        await VideoRecorder.recordStep(tester, 'about', '01_user_profile');

        await tester.tap(tile);
        await tester.pump();
        await pumpUntilFound(tester, find.byType(AboutPage));

        // Verify About Page is shown
        expect(find.byType(AboutPage), findsOneWidget);
        expect(find.text('Sobre OrionHealth'), findsOneWidget);

        // Wait for the real data to be loaded by AboutCubit
        final realMissionStatement = find.textContaining(
          'Creemos que la salud es el activo más valioso',
        );
        await pumpUntilFound(tester, realMissionStatement);
        await VideoRecorder.recordStep(tester, 'about', '02_about_loaded');

        // Verify real content from AboutLocalDataSource is displayed
        expect(realMissionStatement, findsOneWidget);
        expect(
          find.textContaining('La privacidad médica es un derecho fundamental'),
          findsOneWidget,
        );

        // Scroll to blog section
        final blogTitle = find.text('Nuestro Blog de Salud');
        await tester.scrollUntilVisible(blogTitle, 200);
        await tester.pumpAndSettle();
        await VideoRecorder.recordStep(tester, 'about', '03_blog_section');

        // Verify real blog posts are loaded
        final realBlogPostTitle = find.text(
          'Avances médicos que impactan tu salud',
        );
        expect(realBlogPostTitle, findsOneWidget);

        // Interaction: Tap on "Leer más"
        final readMoreButtons = find.text('Leer más');
        expect(readMoreButtons, findsWidgets);
        await tester.tap(readMoreButtons.first);
        await tester.pumpAndSettle();

        await VideoRecorder.recordStep(
          tester,
          'about',
          '04_interaction_complete',
        );
      },
    );
  });
}
