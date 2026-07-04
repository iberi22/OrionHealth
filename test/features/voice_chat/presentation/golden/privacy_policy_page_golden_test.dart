import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:orionhealth_health/features/voice_chat/presentation/pages/privacy_policy_page.dart';
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

  group('PrivacyPolicyPage Golden Tests', () {
    testWidgets('PrivacyPolicyPage - Default State', (tester) async {
      setupGoldenTest(tester);
      await tester.pumpWidget(wrapWithMaterial(const PrivacyPolicyPage()));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(PrivacyPolicyPage),
        matchesGoldenFile("goldens/privacy_policy_page.png"),
      );
      resetGoldenTest(tester);
    });
  });
}
