// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:orionhealth_health/features/voice_chat/presentation/pages/voice_chat_page.dart';
import 'package:orionhealth_health/features/voice_chat/application/voice_chat_cubit.dart';
import 'package:orionhealth_health/features/voice_chat/application/voice_chat_state.dart';
import 'package:orionhealth_health/core/services/aicore_service.dart';

class MockVoiceChatCubit extends Mock implements VoiceChatCubit {}
class MockAIService extends Mock implements AIService {}

void main() {
  late MockVoiceChatCubit mockCubit;
  late MockAIService mockAIService;

  setUpAll(() {
    registerFallbackValue(const VoiceChatState());
  });

  setUp(() {
    final getIt = GetIt.instance;
    getIt.reset();
    mockCubit = MockVoiceChatCubit();
    mockAIService = MockAIService();

    // Setup initial state for the cubit
    when(() => mockCubit.state).thenReturn(const VoiceChatState());
    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockCubit.init()).thenAnswer((_) async {});
    when(() => mockCubit.close()).thenAnswer((_) async {});

    when(() => mockAIService.currentState).thenReturn(AIServiceState.ready);
    when(() => mockAIService.initialize()).thenAnswer((_) async {});

    getIt.registerSingleton<VoiceChatCubit>(mockCubit);
    getIt.registerSingleton<AIService>(mockAIService);
  });

  testWidgets('VoiceChatPage renders initial state correctly', (WidgetTester tester) async {
    when(() => mockCubit.state).thenReturn(const VoiceChatState(
      status: VoiceChatStatus.initial,
      statusMessage: 'Listo para conversar',
    ));

    await tester.pumpWidget(
      const MaterialApp(
        home: VoiceChatPage(),
      ),
    );

    expect(find.text('Orion — Chat de Voz'), findsOneWidget);
    expect(find.text('Listo para conversar'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('VoiceChatPage renders loading state', (WidgetTester tester) async {
    when(() => mockCubit.state).thenReturn(const VoiceChatState(
      status: VoiceChatStatus.loading,
    ));

    await tester.pumpWidget(
      const MaterialApp(
        home: VoiceChatPage(),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('VoiceChatPage has back button', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: VoiceChatPage(),
      ),
    );

    expect(find.byIcon(Icons.arrow_back), findsOneWidget);
  });
}
