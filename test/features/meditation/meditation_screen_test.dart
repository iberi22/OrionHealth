import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orionhealth_health/features/meditation/application/meditation_cubit.dart';
import 'package:orionhealth_health/features/meditation/application/meditation_state.dart';
import 'package:orionhealth_health/features/meditation/presentation/meditation_page.dart';
import 'package:orionhealth_health/features/meditation/domain/entities/meditation_script.dart';
import 'package:orionhealth_health/features/meditation/domain/entities/meditation_category.dart';

class MockMeditationCubit extends Mock implements MeditationCubit {}

void main() {
  late MockMeditationCubit mockCubit;

  setUp(() {
    mockCubit = MockMeditationCubit();
    when(() => mockCubit.state).thenReturn(const MeditationState());
    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockCubit.initialize()).thenAnswer((_) async {});
    when(() => mockCubit.close()).thenAnswer((_) async {});
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<MeditationCubit>.value(
        value: mockCubit,
        child: const MeditationView(),
      ),
    );
  }

  testWidgets('MeditationView renders title in AppBar',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('Meditación Guiada'), findsOneWidget);
  });

  testWidgets('MeditationView shows loading indicator when status is loading',
      (WidgetTester tester) async {
    when(() => mockCubit.state).thenReturn(
      const MeditationState(status: MeditationStatus.loading),
    );

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('MeditationView shows welcome view when status is idle',
      (WidgetTester tester) async {
    const script = MeditationScript(
      id: 'test-01',
      title: 'Respiración Guiada',
      category: MeditationCategory.breathing,
      durationMinutes: 5,
      steps: ['Inhala', 'Exhala'],
    );
    when(() => mockCubit.state).thenReturn(
      const MeditationState(status: MeditationStatus.idle, script: script),
    );

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('Respiración Guiada'), findsOneWidget);
    expect(find.text('Comenzar'), findsOneWidget);
  });

  testWidgets('MeditationView has close button', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.byIcon(Icons.close), findsOneWidget);
  });
}
