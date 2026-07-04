// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:orionhealth_health/features/voice_chat/presentation/pages/chat_page.dart';
import 'package:orionhealth_health/features/voice_chat/presentation/pages/privacy_policy_page.dart';
import 'package:orionhealth_health/features/voice_chat/presentation/pages/voice_chat_page.dart';
import 'package:orionhealth_health/features/voice_chat/application/voice_chat_cubit.dart';
import 'package:orionhealth_health/features/voice_chat/application/voice_chat_state.dart';
import 'package:orionhealth_health/core/services/aicore_service.dart';
import '../../../../core/golden_test_utils.dart';

class MockVoiceChatCubit extends Mock implements VoiceChatCubit {}
class MockAIService extends Mock implements AIService {}

void main() {
  late MockVoiceChatCubit mockCubit;
  late MockAIService mockAIService;

  setUpAll(() {
    registerFallbackValue(const VoiceChatState());
  });

  setUp(() async {
    mockCubit = MockVoiceChatCubit();
    mockAIService = MockAIService();
    final getIt = GetIt.I;
    if (getIt.isRegistered<VoiceChatCubit>()) {
      await getIt.unregister<VoiceChatCubit>();
    }
    if (getIt.isRegistered<AIService>()) {
      await getIt.unregister<AIService>();
    }
    getIt.registerSingleton<VoiceChatCubit>(mockCubit);
    getIt.registerSingleton<AIService>(mockAIService);

    when(() => mockCubit.state).thenReturn(const VoiceChatState());
    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockCubit.init()).thenAnswer((_) async {});
    when(() => mockCubit.close()).thenAnswer((_) async {});
    when(() => mockAIService.currentState).thenReturn(AIServiceState.ready);
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  group('Voice Chat Pages Golden Tests', () {
    testWidgets('ChatPage', (tester) async {
      setupGoldenTest(tester);
      await tester.pumpWidget(wrapWithMaterial(const ChatPage()));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(ChatPage),
        matchesGoldenFile("../../../../../golden/reference/voice_chat_page_alt.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('PrivacyPolicyPage', (tester) async {
      setupGoldenTest(tester);
      await tester.pumpWidget(wrapWithMaterial(const PrivacyPolicyPage()));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(PrivacyPolicyPage),
        matchesGoldenFile("../../../../../golden/reference/voice_chat_privacy_policy.png"),
      );
      resetGoldenTest(tester);
    });

    testWidgets('VoiceChatPage', (tester) async {
      setupGoldenTest(tester);
      // Large size to avoid overflow in ConnectionStatusIndicator
      tester.view.physicalSize = const Size(600, 1000);

      when(() => mockCubit.state).thenReturn(const VoiceChatState(
        status: VoiceChatStatus.recording,
        statusMessage: 'Escuchando...',
      ));

      await tester.pumpWidget(wrapWithMaterial(const VoiceChatPage()));
      await tester.pump(const Duration(milliseconds: 500));

      await expectLater(
        find.byType(VoiceChatPage),
        matchesGoldenFile("../../../../../golden/reference/voice_chat_page.png"),
      );
      resetGoldenTest(tester);
    });
  });
}
