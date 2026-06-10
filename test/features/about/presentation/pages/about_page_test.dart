import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:orionhealth_health/features/about/presentation/pages/about_page.dart';
import 'package:orionhealth_health/features/about/presentation/widgets/mission_section.dart';
import 'package:orionhealth_health/features/about/application/about_cubit.dart';
import 'package:orionhealth_health/features/about/domain/entities/about_info.dart';

class MockAboutCubit extends Mock implements AboutCubit {}

void main() {
  late MockAboutCubit mockAboutCubit;

  setUpAll(() {
    mockAboutCubit = MockAboutCubit();
    final getIt = GetIt.instance;
    getIt.registerLazySingleton<AboutCubit>(() => mockAboutCubit);
  });

  tearDownAll(() async {
    await GetIt.instance.reset();
  });

  testWidgets('AboutPage displays mission section and blog posts', (WidgetTester tester) async {
    const aboutInfo = AboutInfo(
      blogPosts: [
        BlogPost(
          title: 'Test Blog Post',
          content: 'Test Content',
          date: '2024-05-10',
          category: 'Test Category',
        ),
      ],
      missionStatement: 'Test Mission',
      values: ['Value 1'],
      activities: ['Activity 1'],
    );

    when(() => mockAboutCubit.state).thenReturn(const AboutLoaded(aboutInfo));
    when(() => mockAboutCubit.loadAboutInfo()).thenAnswer((_) async {});
    when(() => mockAboutCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockAboutCubit.close()).thenAnswer((_) async {});

    // Set a larger surface size
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(
      const MaterialApp(
        home: AboutPage(),
      ),
    );

    await tester.pump();

    // Check if the title is present
    expect(find.text('Sobre OrionHealth'), findsOneWidget);

    // Check if MissionSection is present
    expect(find.byType(MissionSection), findsOneWidget);

    // Check if mission statement is displayed
    expect(find.text('Test Mission'), findsOneWidget);

    // Scroll down to find the blog section if it's not in view
    await tester.scrollUntilVisible(find.text('Nuestro Blog de Salud'), 500.0);

    // Check if blog section header is present
    expect(find.text('Nuestro Blog de Salud'), findsOneWidget);

    // Check if the mock blog post title is present
    expect(find.text('Test Blog Post'), findsOneWidget);

    // Reset view
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  });
}
