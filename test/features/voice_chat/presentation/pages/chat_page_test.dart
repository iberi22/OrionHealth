// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/voice_chat/presentation/pages/chat_page.dart';
import 'package:orionhealth_health/features/voice_chat/presentation/pages/voice_chat_page.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
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

    when(() => mockCubit.state).thenReturn(const VoiceChatState());
    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockCubit.init()).thenAnswer((_) async {});
    when(() => mockCubit.close()).thenAnswer((_) async {});

    when(() => mockAIService.currentState).thenReturn(AIServiceState.ready);

    getIt.registerSingleton<VoiceChatCubit>(mockCubit);
    getIt.registerSingleton<AIService>(mockAIService);
  });

  testWidgets('ChatPage renders and has button to VoiceChatPage', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ChatPage()));

    expect(find.text('Chat (Offline)'), findsOneWidget);
    expect(find.textContaining('Orion ahora funciona en modo chat de voz'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
    expect(find.text('Ir al Chat de Voz'), findsOneWidget);
  });
}
