import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
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

  group('VoiceChatPage Golden Tests', () {
    testWidgets('VoiceChatPage - Recording State', (tester) async {
      setupGoldenTest(tester);
      // Even larger size to avoid overflow in ConnectionStatusIndicator
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
