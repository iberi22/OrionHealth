// SPDX-License-Identifier: AGPL-3.0-only
// SPDX-FileCopyrightText: 2025 SouthWest AI Labs

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/voice_chat/application/voice_chat_cubit.dart';
import 'package:orionhealth_health/features/voice_chat/application/voice_chat_state.dart';
import 'package:orionhealth_health/features/voice_chat/presentation/widgets/voice_input_button.dart';

class MockVoiceChatCubit extends Mock implements VoiceChatCubit {}

void main() {
  late MockVoiceChatCubit mockCubit;

  setUp(() {
    mockCubit = MockVoiceChatCubit();
  });

  Widget createWidgetUnderTest() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<VoiceChatCubit>.value(value: mockCubit),
      ],
      child: const MaterialApp(
        home: Scaffold(
          body: VoiceInputButton(),
        ),
      ),
    );
  }

  testWidgets('VoiceInputButton shows initial state', (tester) async {
    when(() => mockCubit.state).thenReturn(const VoiceChatState(status: VoiceChatStatus.initial));
    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.byIcon(Icons.mic_none), findsOneWidget);
    expect(find.text('Mantén para hablar'), findsOneWidget);
  });

  testWidgets('VoiceInputButton shows recording state', (tester) async {
    when(() => mockCubit.state).thenReturn(const VoiceChatState(status: VoiceChatStatus.recording));
    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.byIcon(Icons.mic), findsOneWidget);
    expect(find.text('Suelta para enviar'), findsOneWidget);
  });

  testWidgets('VoiceInputButton shows processing state', (tester) async {
    when(() => mockCubit.state).thenReturn(const VoiceChatState(status: VoiceChatStatus.processing));
    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('VoiceInputButton shows speaking state with interrupt button', (tester) async {
    when(() => mockCubit.state).thenReturn(const VoiceChatState(status: VoiceChatStatus.speaking));
    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.byIcon(Icons.stop), findsOneWidget);
    expect(find.text('Interrumpir'), findsOneWidget);
  });

  testWidgets('VoiceInputButton triggers startRecording on long press start', (tester) async {
    when(() => mockCubit.state).thenReturn(const VoiceChatState(status: VoiceChatStatus.initial));
    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockCubit.startRecording()).thenAnswer((_) async {});
    when(() => mockCubit.stopRecording()).thenAnswer((_) async => null);

    await tester.pumpWidget(createWidgetUnderTest());

    await tester.longPress(find.byType(VoiceInputButton));

    verify(() => mockCubit.startRecording()).called(1);
    verify(() => mockCubit.stopRecording()).called(1);
  });
}
