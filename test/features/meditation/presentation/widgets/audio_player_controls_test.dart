import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/meditation/presentation/widgets/audio_player_controls.dart';

void main() {
  testWidgets('AudioPlayerControls renders icons and handles clicks', (tester) async {
    bool previousCalled = false;
    bool toggleCalled = false;
    bool nextCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AudioPlayerControls(
            isPlaying: false,
            onPrevious: () => previousCalled = true,
            onTogglePause: () => toggleCalled = true,
            onNext: () => nextCalled = true,
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.skip_previous), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    expect(find.byIcon(Icons.skip_next), findsOneWidget);

    await tester.tap(find.byIcon(Icons.skip_previous));
    expect(previousCalled, isTrue);

    await tester.tap(find.byIcon(Icons.play_arrow));
    expect(toggleCalled, isTrue);

    await tester.tap(find.byIcon(Icons.skip_next));
    expect(nextCalled, isTrue);
  });

  testWidgets('AudioPlayerControls shows pause icon when playing', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AudioPlayerControls(
            isPlaying: true,
            onPrevious: () {},
            onTogglePause: () {},
            onNext: () {},
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.pause), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow), findsNothing);
  });
}
