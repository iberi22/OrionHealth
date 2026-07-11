import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/core/di/injection.dart' as di;
import 'package:orionhealth_health/features/about/presentation/pages/about_page.dart';
import 'package:orionhealth_health/features/about/domain/entities/about_info.dart';
import 'package:orionhealth_health/features/about/domain/repositories/i_about_repository.dart';
import 'package:orionhealth_health/features/user_profile/presentation/pages/user_profile_page.dart';
import 'package:orionhealth_health/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'utils/video_recorder.dart';

class MockAboutRepository extends Mock implements IAboutRepository {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockAboutRepository mockRepository;

  setUpAll(() async {
    await di.configureDependencies();
  });

  setUp(() {
    mockRepository = MockAboutRepository();
    di.getIt.allowReassignment = true;
    di.getIt.registerSingleton<IAboutRepository>(mockRepository);
  });

  tearDown(() {
    di.getIt.unregister<IAboutRepository>();
  });

  Widget createAboutTestWidget(Widget home) {
    return MaterialApp(
      home: home,
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

  group('About Flow - True E2E Tests', () {
    testWidgets('E2E: Navigation to About Page from Profile and Basic Interaction', (WidgetTester tester) async {
      final aboutInfo = AboutInfo(
        missionStatement: 'Nuestra misión es empoderar a los pacientes a través de la tecnología.',
        values: ['Privacidad Primero', 'Seguridad'],
        activities: ['Gestión de historial', 'IA local'],
        blogPosts: List.generate(5, (i) => BlogPost(
          title: 'Post de prueba $i',
          content: 'Contenido del post $i que debe ser lo suficientemente largo para probar el scroll.',
          date: '10 Jun 2026',
          category: 'Noticias',
        )),
      );

      when(() => mockRepository.getAboutInfo()).thenAnswer((_) async => aboutInfo);

      // Start from User Profile to test navigation
      await tester.pumpWidget(createAboutTestWidget(const UserProfilePage()));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'about', '01_user_profile');

      final l10n = await AppLocalizations.delegate.load(const Locale('es'));

      // Navigate to About OrionHealth
      // In UserProfilePage, the tile text is from l10n.aboutOrionHealth
      final aboutTile = find.text(l10n.aboutOrionHealth);
      await tester.scrollUntilVisible(aboutTile, 100);
      await tester.tap(aboutTile);
      await tester.pumpAndSettle();

      // Verify About Page is shown
      expect(find.byType(AboutPage), findsOneWidget);
      expect(find.text('Sobre OrionHealth'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'about', '02_about_loaded');

      // Verify content
      expect(find.text(aboutInfo.missionStatement), findsOneWidget);
      expect(find.text('Privacidad Primero'), findsOneWidget);

      // Scroll to blog section
      final blogTitle = find.text('Nuestro Blog de Salud');
      await tester.scrollUntilVisible(blogTitle, 200);
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'about', '03_blog_section');

      // Interaction: Tap on "Leer más"
      final readMoreButtons = find.text('Leer más');
      expect(readMoreButtons, findsWidgets);
      await tester.tap(readMoreButtons.first);
      await tester.pumpAndSettle();

      await VideoRecorder.recordStep(tester, 'about', '04_interaction_complete');
    });

    testWidgets('E2E: About Page Error State', (WidgetTester tester) async {
      const errorMessage = 'No se pudo cargar la información';
      when(() => mockRepository.getAboutInfo()).thenThrow(Exception(errorMessage));

      await tester.pumpWidget(createAboutTestWidget(const AboutPage()));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'about', '05_error_state');

      expect(find.textContaining(errorMessage), findsOneWidget);
    });
  });
}
