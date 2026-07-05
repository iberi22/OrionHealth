import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/core/di/injection.dart' as di;
import 'package:orionhealth_health/features/about/presentation/pages/about_page.dart';
import 'package:orionhealth_health/features/about/domain/entities/about_info.dart';
import 'package:orionhealth_health/features/about/domain/repositories/i_about_repository.dart';
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

  group('About Flow - True E2E Tests', () {
    testWidgets('E2E: About Page Loading and Loaded State', (WidgetTester tester) async {
      final completer = Completer<AboutInfo>();

      const aboutInfo = AboutInfo(
        missionStatement: 'Nuestra misión es empoderar a los pacientes a través de la tecnología.',
        values: ['Privacidad Primero', 'Seguridad'],
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

      when(() => mockRepository.getAboutInfo()).thenAnswer((_) => completer.future);

      await tester.pumpWidget(const MaterialApp(home: AboutPage()));

      // Verify loading state
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await VideoRecorder.recordStep(tester, 'about', '01_loading');

      // Complete the future to move to loaded state
      completer.complete(aboutInfo);
      await tester.pumpAndSettle();

      await VideoRecorder.recordStep(tester, 'about', '02_loaded');

      expect(find.text('Sobre OrionHealth'), findsOneWidget);
      expect(find.text(aboutInfo.missionStatement), findsOneWidget);
      expect(find.text('Privacidad Primero'), findsOneWidget);
      expect(find.text('El futuro de la salud soberana'), findsOneWidget);
    });

    testWidgets('E2E: About Page Error State', (WidgetTester tester) async {
      const errorMessage = 'No se pudo cargar la información';
      when(() => mockRepository.getAboutInfo()).thenThrow(Exception(errorMessage));

      await tester.pumpWidget(const MaterialApp(home: AboutPage()));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'about', '03_error');

      expect(find.textContaining(errorMessage), findsOneWidget);
    });
  });
}
