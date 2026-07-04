import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:orionhealth_health/features/about/presentation/pages/about_page.dart';
import 'package:orionhealth_health/features/about/application/about_cubit.dart';
import 'package:orionhealth_health/features/about/domain/entities/about_info.dart';
import '../../../../core/golden_test_utils.dart';

class MockAboutCubit extends Mock implements AboutCubit {}

void main() {
  late MockAboutCubit mockCubit;

  setUpAll(() {
    initializeDateFormatting('es', null);
  });

  setUp(() async {
    mockCubit = MockAboutCubit();
    await GetIt.I.reset();
    GetIt.I.registerSingleton<AboutCubit>(mockCubit);

    when(() => mockCubit.loadAboutInfo()).thenAnswer((_) async {});
    when(() => mockCubit.close()).thenAnswer((_) async {});
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  group('About Page Golden Tests', () {
    testWidgets('About Page - Loaded', (tester) async {
      setupGoldenTest(tester);

      const aboutInfo = AboutInfo(
        missionStatement: 'Nuestra misión es empoderar a los pacientes a través de la tecnología y el acceso a sus propios datos de salud.',
        values: [
          'Privacidad Primero',
          'Interoperabilidad',
          'Centrado en el Paciente',
          'Seguridad de Grado Médico',
        ],
        activities: [
          'Gestión de historial clínico electrónico',
          'Sincronización con nodos locales de salud',
          'Análisis preventivo mediante IA local',
        ],
        blogPosts: [
          BlogPost(
            title: 'El futuro de la salud soberana',
            content: 'Los datos de salud pertenecen al paciente, no a las instituciones. En OrionHealth trabajamos para que esto sea una realidad diaria.',
            date: '10 Jun 2026',
            category: 'Noticias',
          ),
          BlogPost(
            title: 'Seguridad en la red Orion',
            content: 'Implementamos protocolos de cifrado de extremo a extremo para asegurar que solo tú y tus médicos autorizados vean tu información.',
            date: '05 Jun 2026',
            category: 'Seguridad',
          ),
        ],
      );

      when(() => mockCubit.state).thenReturn(const AboutLoaded(aboutInfo));
      when(() => mockCubit.stream).thenAnswer((_) => Stream.fromIterable([const AboutLoaded(aboutInfo)]));

      await tester.pumpWidget(wrapWithMaterial(const AboutPage()));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(AboutPage),
        matchesGoldenFile("goldens/about_page_loaded.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('About Page - Error', (tester) async {
      setupGoldenTest(tester);

      const state = AboutError('Error al cargar la información de la empresa');

      when(() => mockCubit.state).thenReturn(state);
      when(() => mockCubit.stream).thenAnswer((_) => Stream.fromIterable([state]));

      await tester.pumpWidget(wrapWithMaterial(const AboutPage()));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(AboutPage),
        matchesGoldenFile("goldens/about_page_error.png"),
      );
      resetGoldenTest(tester);
    });
  });
}
