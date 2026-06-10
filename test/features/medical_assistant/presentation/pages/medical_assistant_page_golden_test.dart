import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:orionhealth_health/features/medical_assistant/presentation/pages/medical_assistant_page.dart';
import 'package:orionhealth_health/features/medical_assistant/application/medical_assistant_cubit.dart';
import 'package:orionhealth_health/features/medical_assistant/domain/entities/medical_insight.dart';
import 'package:orionhealth_health/features/medical_assistant/domain/entities/ai_response.dart';
import 'package:orionhealth_health/features/medical_assistant/domain/entities/medical_query.dart';

class MockMedicalAssistantCubit extends Mock implements MedicalAssistantCubit {}

void main() {
  late MockMedicalAssistantCubit mockCubit;

  setUpAll(() {
    final getIt = GetIt.instance;
    mockCubit = MockMedicalAssistantCubit();
    getIt.registerLazySingleton<MedicalAssistantCubit>(() => mockCubit);
  });

  tearDownAll(() {
    GetIt.I.reset();
  });

  group('Medical Assistant Golden Tests', () {
    testWidgets('MedicalAssistantPage - Idle', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;

      when(() => mockCubit.state).thenReturn(MedicalAssistantIdle());
      when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(const MaterialApp(home: MedicalAssistantPage()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await expectLater(
        find.byType(MedicalAssistantPage),
        matchesGoldenFile('goldens/medical_assistant_idle.png'),
      );
    });

    testWidgets('MedicalAssistantPage - Response with Insights/Labs', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      final now = DateTime.now();
      final response = AiMedicalResponse(
        id: 'resp-1',
        queryId: 'q-1',
        answer: 'Tus niveles de glucosa son ligeramente elevados.',
        confidence: 0.92,
        generatedAt: now,
        insights: [
          MedicalInsight(
            id: 'ins-1',
            title: 'Glucosa Elevada',
            description: 'Nivel alto.',
            category: InsightCategory.labInterpretation,
            severity: InsightSeverity.warning,
            generatedAt: now,
          ),
        ],
      );

      final query = MedicalQuery(
        id: 'q-1',
        question: '¿Cómo están mis niveles?',
        timestamp: now,
      );

      when(() => mockCubit.state).thenReturn(MedicalAssistantResponse(
        query: query,
        response: response,
      ));
      when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(const MaterialApp(home: MedicalAssistantPage()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await expectLater(
        find.byType(MedicalAssistantPage),
        matchesGoldenFile('goldens/medical_assistant_response.png'),
      );
    });
  });
}
