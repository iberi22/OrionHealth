import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:orionhealth_health/features/about/presentation/pages/about_page.dart';
import 'package:orionhealth_health/features/about/application/about_cubit.dart';
import 'package:orionhealth_health/features/about/domain/entities/about_info.dart';
import 'utils/video_recorder.dart';

class MockAboutCubit extends Mock implements AboutCubit {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockAboutCubit mockCubit;

  setUp(() async {
    mockCubit = MockAboutCubit();
    await GetIt.I.reset();
    GetIt.I.registerFactory<AboutCubit>(() => mockCubit);

    when(() => mockCubit.loadAboutInfo()).thenAnswer((_) async {});
    when(() => mockCubit.close()).thenAnswer((_) async {});
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  group('About Flow - E2E Tests', () {
    testWidgets('E2E: About Page Loading State', (WidgetTester tester) async {
      when(() => mockCubit.state).thenReturn(const AboutLoading());
      when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(const MaterialApp(home: AboutPage()));
      await VideoRecorder.recordStep(tester, 'about', '01_loading');

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('E2E: About Page Loaded State', (WidgetTester tester) async {
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

      when(() => mockCubit.state).thenReturn(const AboutLoaded(aboutInfo));
      when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(const MaterialApp(home: AboutPage()));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'about', '02_loaded');

      expect(find.text('Sobre OrionHealth'), findsOneWidget);
      expect(find.text(aboutInfo.missionStatement), findsOneWidget);
      expect(find.text('Privacidad Primero'), findsOneWidget);
      expect(find.text('El futuro de la salud soberana'), findsOneWidget);
    });

    testWidgets('E2E: About Page Error State', (WidgetTester tester) async {
      const errorMessage = 'No se pudo cargar la información';
      when(() => mockCubit.state).thenReturn(const AboutError(errorMessage));
      when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(const MaterialApp(home: AboutPage()));
      await tester.pumpAndSettle();
      await VideoRecorder.recordStep(tester, 'about', '03_error');

      expect(find.text('Error: $errorMessage'), findsOneWidget);
    });
  });
}
