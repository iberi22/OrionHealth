import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:orionhealth_health/core/di/injection.dart' as di;
import 'package:orionhealth_health/features/about/presentation/pages/about_page.dart';
import 'package:orionhealth_health/features/about/domain/repositories/i_about_repository.dart';
import 'package:orionhealth_health/features/about/domain/entities/about_info.dart';
import 'utils/video_recorder.dart';

class MockAboutRepository extends Mock implements IAboutRepository {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockAboutRepository mockRepo;

  setUpAll(() async {
    // Initialize real dependencies
    await di.configureDependencies();
    // Allow overrides in GetIt
    di.getIt.allowReassignment = true;
  });

  setUp(() {
    mockRepo = MockAboutRepository();
    // Register the mock repository as an override
    di.getIt.registerSingleton<IAboutRepository>(mockRepo);
  });

  tearDown(() {
    // Clean up the override
    di.getIt.unregister<IAboutRepository>();
  });

  group('About Flow - E2E Tests (True E2E)', () {
    testWidgets('E2E: About Page States - Loading, Loaded, and Error', (WidgetTester tester) async {
      final completer = Completer<AboutInfo>();
      when(() => mockRepo.getAboutInfo()).thenAnswer((_) => completer.future);

      // 1. LOADING STATE
      // AboutPage triggers loadAboutInfo in its BlocProvider's create
      await tester.pumpWidget(const MaterialApp(home: AboutPage()));

      // Initial pump to trigger the build and the Cubit's load call
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'about', '01_loading');

      // 2. LOADED STATE
      const aboutInfo = AboutInfo(
        missionStatement: 'Nuestra misión es empoderar a los pacientes a través de la tecnología.',
        values: ['Privacidad Primero', 'Seguridad de Datos'],
        activities: ['Gestión de historial', 'IA local'],
        blogPosts: [
          BlogPost(
            title: 'El futuro de la salud soberana',
            content: 'Los datos de salud pertenecen al paciente.',
            date: '10 Jun 2026',
            category: 'Noticias',
          ),
        ],
      );

      completer.complete(aboutInfo);
      // Wait for the state transition and UI rebuild
      await tester.pumpAndSettle();

      expect(find.text('Sobre OrionHealth'), findsOneWidget);
      expect(find.text(aboutInfo.missionStatement), findsOneWidget);
      expect(find.text('Privacidad Primero'), findsOneWidget);
      expect(find.text('El futuro de la salud soberana'), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'about', '02_loaded');

      // 3. ERROR STATE
      // We recreate the page to trigger a new load call with an error response
      final errorCompleter = Completer<AboutInfo>();
      when(() => mockRepo.getAboutInfo()).thenAnswer((_) => errorCompleter.future);

      await tester.pumpWidget(const MaterialApp(home: AboutPage()));
      await tester.pump();

      const errorMessage = 'No se pudo cargar la información de la red';
      errorCompleter.completeError(Exception(errorMessage));
      await tester.pumpAndSettle();

      // The UI shows 'Error: Exception: ...' when catching an exception in the cubit
      expect(find.textContaining(errorMessage), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'about', '03_error');
    });
  });
}
