import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orionhealth_health/features/about/application/about_cubit.dart';
import 'package:orionhealth_health/features/about/presentation/pages/about_page.dart';
import 'package:orionhealth_health/core/di/injection.dart';

class MockAboutCubit extends Mock implements AboutCubit {}

void main() {
  late MockAboutCubit mockAboutCubit;

  setUpAll(() {
    mockAboutCubit = MockAboutCubit();
    getIt.registerSingleton<AboutCubit>(mockAboutCubit);
  });

  testWidgets('renders Error message when state is AboutError', (tester) async {
    when(() => mockAboutCubit.state).thenReturn(const AboutError('Test Error'));
    when(() => mockAboutCubit.loadAboutInfo()).thenAnswer((_) async {});
    when(() => mockAboutCubit.stream).thenAnswer((_) => Stream.value(const AboutError('Test Error')));

    await tester.pumpWidget(
      const MaterialApp(
        home: AboutPage(),
      ),
    );

    expect(find.text('Error: Test Error'), findsOneWidget);
  });
}
