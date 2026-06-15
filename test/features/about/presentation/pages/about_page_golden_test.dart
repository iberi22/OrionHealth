import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:orionhealth_health/features/about/presentation/pages/about_page.dart';
import 'package:orionhealth_health/features/about/presentation/widgets/mission_section.dart';
import 'package:orionhealth_health/features/about/application/about_cubit.dart';
import 'package:orionhealth_health/features/about/domain/entities/about_info.dart';
import '../../../../core/golden_test_utils.dart';

class MockAboutCubit extends Mock implements AboutCubit {}

void main() {
  late MockAboutCubit mockAboutCubit;

  setUp(() {
    mockAboutCubit = MockAboutCubit();
    GetIt.I.reset();
    GetIt.I.registerLazySingleton<AboutCubit>(() => mockAboutCubit);
  });

  tearDown(() {
    GetIt.I.reset();
  });

  group('AboutPage Golden Tests', () {
    testWidgets('AboutPage - Loading State', (tester) async {
      setupGoldenTest(tester);

      when(() => mockAboutCubit.state).thenReturn(const AboutLoading());
      when(() => mockAboutCubit.loadAboutInfo()).thenAnswer((_) async {});
      when(() => mockAboutCubit.stream).thenAnswer((_) => const Stream.empty());
      when(() => mockAboutCubit.close()).thenAnswer((_) async {});

      await tester.pumpWidget(wrapWithMaterial(const AboutPage()));
      await tester.pump();

      await expectLater(
        find.byType(AboutPage),
        matchesGoldenFile('goldens/about_page_loading.png'),
      );
      resetGoldenTest(tester);
    });

    testWidgets('AboutPage - Error State', (tester) async {
      setupGoldenTest(tester);

      when(
        () => mockAboutCubit.state,
      ).thenReturn(const AboutError('Error al cargar información'));
      when(() => mockAboutCubit.loadAboutInfo()).thenAnswer((_) async {});
      when(() => mockAboutCubit.stream).thenAnswer((_) => const Stream.empty());
      when(() => mockAboutCubit.close()).thenAnswer((_) async {});

      await tester.pumpWidget(wrapWithMaterial(const AboutPage()));
      await tester.pump();

      await expectLater(
        find.byType(AboutPage),
        matchesGoldenFile('goldens/about_page_error.png'),
      );
      resetGoldenTest(tester);
    });

    testWidgets('AboutPage - Loaded State', (tester) async {
      setupGoldenTest(tester);

      const aboutInfo = AboutInfo(
        blogPosts: [
          BlogPost(
            title: 'Nuevos horizontes en telemedicina',
            content:
                'Descubre cómo la telemedicina está transformando la atención médica en Colombia, permitiendo consultas remotas seguras y eficientes.',
            date: '2026-06-01',
            category: 'Telemedicina',
          ),
          BlogPost(
            title: 'Salud preventiva: tu mejor aliada',
            content:
                'Conoce las claves para mantener un estilo de vida saludable y prevenir enfermedades crónicas con hábitos diarios simples.',
            date: '2026-05-25',
            category: 'Prevención',
          ),
        ],
        missionStatement:
            'Empoderar a las personas con herramientas digitales para gestionar su salud de manera proactiva, segura y descentralizada.',
        values: [
          'La privacidad del paciente es innegociable',
          'Tecnología accesible para todos',
          'Datos seguros, soberanía del usuario',
        ],
        activities: [
          'Desarrollo de wallet de salud con estándares FHIR',
          'Integración con sistemas de salud colombianos (EPS)',
          'Investigación en IA para diagnósticos asistidos',
        ],
      );

      when(() => mockAboutCubit.state).thenReturn(const AboutLoaded(aboutInfo));
      when(() => mockAboutCubit.loadAboutInfo()).thenAnswer((_) async {});
      when(() => mockAboutCubit.stream).thenAnswer((_) => const Stream.empty());
      when(() => mockAboutCubit.close()).thenAnswer((_) async {});

      await tester.pumpWidget(wrapWithMaterial(const AboutPage()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await expectLater(
        find.byType(AboutPage),
        matchesGoldenFile('goldens/about_page_loaded.png'),
      );
      resetGoldenTest(tester);
    });

    testWidgets('MissionSection widget standalone', (tester) async {
      setupGoldenTest(tester);

      await tester.pumpWidget(
        wrapWithMaterial(
          Scaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: MissionSection(
                  missionStatement: 'Misión de prueba para OrionHealth',
                  values: ['Valor 1: Privacidad', 'Valor 2: Accesibilidad'],
                  activities: [
                    'Actividad 1: Desarrollo',
                    'Actividad 2: Investigación',
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      await expectLater(
        find.byType(MissionSection),
        matchesGoldenFile('goldens/mission_section.png'),
      );
      resetGoldenTest(tester);
    });
  });
}
