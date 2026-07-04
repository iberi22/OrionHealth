import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:orionhealth_health/features/voice_chat/presentation/pages/chat_page.dart';
import 'package:orionhealth_health/features/voice_chat/application/voice_chat_cubit.dart';
import 'package:orionhealth_health/features/voice_chat/application/voice_chat_state.dart';
import '../../../../core/golden_test_utils.dart';

class MockVoiceChatCubit extends Mock implements VoiceChatCubit {}

void main() {
  late MockVoiceChatCubit mockCubit;

  setUp(() async {
    mockCubit = MockVoiceChatCubit();

    await GetIt.I.reset();
    GetIt.I.registerSingleton<VoiceChatCubit>(mockCubit);

    when(() => mockCubit.state).thenReturn(const VoiceChatState());
    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockCubit.close()).thenAnswer((_) async {});
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  group('ChatPage Golden Tests', () {
    testWidgets('ChatPage - Initial', (tester) async {
      setupGoldenTest(tester);
      await tester.pumpWidget(wrapWithMaterial(const ChatPage()));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(ChatPage),
        matchesGoldenFile("goldens/chat_page.png"),
      );
      resetGoldenTest(tester);
    });
  });
}
