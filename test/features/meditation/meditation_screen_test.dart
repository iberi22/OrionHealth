import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/meditation/meditation_models.dart';
import 'package:orionhealth_health/features/meditation/meditation_screen.dart';

/// Stub MeditationService for testing
class TestMeditationService extends MeditationService {
  Future<void> initialize() async {}

  Future<MeditationScript> recommendScript({List<String>? memoryHints}) async {
    return const MeditationScript(
      id: 'test-01',
      title: 'Respiración Guiada',
      category: MeditationCategory.breathing,
      durationMinutes: 5,
      steps: ['Inhala', 'Exhala', 'Relájate'],
    );
  }

  Future<MeditationProgress> getProgress() async {
    return const MeditationProgress(
      totalSessions: 5,
      completedSessions: 3,
      totalCompletedSeconds: 900,
    );
  }

  Future<MeditationSessionRecord> startSession(MeditationScript script) async {
    return MeditationSessionRecord(
      id: 'session-1',
      scriptId: script.id,
      category: script.category,
      startedAt: DateTime.now(),
    );
  }

  Future<void> completeSession({
    required MeditationSessionRecord session,
    required int elapsedSeconds,
    required int completedSteps,
  }) async {}
}

/// Widget test for MeditationScreen with all dependencies provided
/// to avoid compiling against missing service classes (AudioService,
/// AgentMemoryService).
void main() {
  late TestMeditationService testService;

  setUp(() {
    testService = TestMeditationService();
  });

  testWidgets('MeditationScreen renders title in AppBar',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MeditationScreen(
          meditationService: testService as dynamic,
          initializeAudio: () async {},
          speakText: (String text) async {},
          stopTts: () async {},
          stopAll: () async {},
          loadMemoryHints: () async => [],
        ),
      ),
    );

    expect(find.text('Meditacion Guiada'), findsOneWidget);
  });

  testWidgets('MeditationScreen shows loading indicator initially',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MeditationScreen(
          meditationService: testService as dynamic,
          initializeAudio: () async {},
          speakText: (String text) async {},
          stopTts: () async {},
          stopAll: () async {},
          loadMemoryHints: () async => [],
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Preparando meditacion local...'), findsOneWidget);
  });

  testWidgets('MeditationScreen has close button', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MeditationScreen(
          meditationService: testService as dynamic,
          initializeAudio: () async {},
          speakText: (String text) async {},
          stopTts: () async {},
          stopAll: () async {},
          loadMemoryHints: () async => [],
        ),
      ),
    );

    expect(find.byIcon(Icons.close), findsOneWidget);
  });

  testWidgets('MeditationScreen renders Scaffold with gradient',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MeditationScreen(
          meditationService: testService as dynamic,
          initializeAudio: () async {},
          speakText: (String text) async {},
          stopTts: () async {},
          stopAll: () async {},
          loadMemoryHints: () async => [],
        ),
      ),
    );

    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.byType(DecoratedBox), findsOneWidget);
  });
}
