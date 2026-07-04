import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/about/application/about_cubit.dart';
import 'package:orionhealth_health/features/about/domain/entities/about_info.dart';
import 'package:orionhealth_health/features/about/presentation/pages/about_page.dart';
import 'package:orionhealth_health/core/di/injection.dart';

class MockAboutCubit extends Mock implements AboutCubit {}

void main() {
  late MockAboutCubit mockAboutCubit;

  setUpAll(() {
    mockAboutCubit = MockAboutCubit();
    getIt.registerSingleton<AboutCubit>(mockAboutCubit);
  });

  testWidgets('renders blog section title', (tester) async {
    const tAboutInfo = AboutInfo(
      blogPosts: [],
      missionStatement: 'Test Mission',
      values: ['Value 1'],
      activities: ['Activity 1'],
    );
    when(() => mockAboutCubit.state).thenReturn(const AboutLoaded(tAboutInfo));
    when(() => mockAboutCubit.loadAboutInfo()).thenAnswer((_) async {});
    when(() => mockAboutCubit.stream).thenAnswer((_) => Stream.value(const AboutLoaded(tAboutInfo)));

    await tester.pumpWidget(
      const MaterialApp(
        home: AboutPage(),
      ),
    );

    expect(find.text('Nuestro Blog de Salud'), findsOneWidget);
  });
}
