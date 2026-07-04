import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:orionhealth_health/features/about/presentation/pages/about_page.dart';
import 'package:orionhealth_health/features/about/application/about_cubit.dart';
import 'package:orionhealth_health/features/about/domain/entities/about_info.dart';
import '../../../../core/golden_test_utils.dart';

class MockAboutCubit extends Mock implements AboutCubit {}

void main() {
  late MockAboutCubit mockAboutCubit;

  final sampleAboutInfo = AboutInfo(
    missionStatement: 'Nuestra misión es transformar la salud a través de la tecnología y el acceso universal.',
    values: [
      'Privacidad por diseño',
      'Empoderamiento del paciente',
      'Excelencia clínica',
    ],
    activities: [
      'Desarrollo de IA para diagnóstico',
      'Integración de registros médicos universales',
      'Seguimiento preventivo proactivo',
    ],
    blogPosts: [
      const BlogPost(
        title: 'El futuro de la salud digital',
        content: 'Exploramos cómo la inteligencia artificial está cambiando la medicina preventiva.',
        date: '2024-03-20',
        category: 'Tecnología',
      ),
      const BlogPost(
        title: 'Consejos para una vida saludable',
        content: 'Pequeños cambios en tu rutina diaria pueden tener un gran impacto.',
        date: '2024-03-15',
        category: 'Bienestar',
      ),
    ],
  );

  setUp(() {
    mockAboutCubit = MockAboutCubit();
    GetIt.I.registerFactory<AboutCubit>(() => mockAboutCubit);

    when(() => mockAboutCubit.loadAboutInfo()).thenAnswer((_) async => {});
    when(() => mockAboutCubit.close()).thenAnswer((_) async => {});
  });

  tearDown(() {
    GetIt.I.reset();
  });

  group('AboutPage Golden Tests', () {
    testWidgets('AboutPage - Loaded State', (tester) async {
      setupGoldenTest(tester);
      when(() => mockAboutCubit.state).thenReturn(AboutLoaded(sampleAboutInfo));
      when(() => mockAboutCubit.stream).thenAnswer((_) => Stream.value(AboutLoaded(sampleAboutInfo)));

      await tester.pumpWidget(wrapWithMaterial(const AboutPage()));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(AboutPage),
        matchesGoldenFile("../../../../golden/reference/about_page_loaded.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('AboutPage - Loading State', (tester) async {
      setupGoldenTest(tester);
      when(() => mockAboutCubit.state).thenReturn(const AboutLoading());
      when(() => mockAboutCubit.stream).thenAnswer((_) => Stream.value(const AboutLoading()));

      await tester.pumpWidget(wrapWithMaterial(const AboutPage()));
      await tester.pump(const Duration(milliseconds: 500)); // To show spinner

      await expectLater(
        find.byType(AboutPage),
        matchesGoldenFile("../../../../golden/reference/about_page_loading.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('AboutPage - Error State', (tester) async {
      setupGoldenTest(tester);
      when(() => mockAboutCubit.state).thenReturn(const AboutError('Failed to load about info'));
      when(() => mockAboutCubit.stream).thenAnswer((_) => Stream.value(const AboutError('Failed to load about info')));

      await tester.pumpWidget(wrapWithMaterial(const AboutPage()));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(AboutPage),
        matchesGoldenFile("../../../../golden/reference/about_page_error.png"),
      );
      resetGoldenTest(tester);
    });
  });
}
