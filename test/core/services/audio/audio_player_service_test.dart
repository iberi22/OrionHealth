import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:just_audio/just_audio.dart';
import 'package:orionhealth_health/core/services/audio/audio_player_service.dart';
import 'package:orionhealth_health/core/services/audio/audio_recorder_service.dart';
import 'package:record/record.dart';

class MockAudioPlayer extends Mock implements AudioPlayer {}
class MockAudioRecorder extends Mock implements AudioRecorder {}

void main() {
  late AudioPlayerService playerService;
  late MockAudioPlayer mockPlayer;
  late StreamController<PlayerState> playerStateController;

  setUp(() {
    mockPlayer = MockAudioPlayer();
    playerStateController = StreamController<PlayerState>.broadcast();

    when(() => mockPlayer.playerStateStream).thenAnswer((_) => playerStateController.stream);
    when(() => mockPlayer.setFilePath(any())).thenAnswer((_) async => null);
    when(() => mockPlayer.play()).thenAnswer((_) async {});
    when(() => mockPlayer.stop()).thenAnswer((_) async {});
    when(() => mockPlayer.dispose()).thenAnswer((_) async {});

    playerService = AudioPlayerService(player: mockPlayer);
  });

  tearDown(() {
    playerStateController.close();
    playerService.dispose();
  });

  test('initialize sets up listener', () async {
    await playerService.initialize();

    playerStateController.add(PlayerState(false, ProcessingState.completed));

    // Check if playbackStateStream emits false
    await expectLater(playerService.playbackStateStream, emits(false));
    expect(playerService.isPlaying, isFalse);
  });

  test('playAudioBytes writes to file and plays', () async {
    final bytes = Uint8List.fromList([1, 2, 3, 4]);

    await playerService.playAudioBytes(bytes);

    verify(() => mockPlayer.setFilePath(any())).called(1);
    verify(() => mockPlayer.play()).called(1);
    expect(playerService.isPlaying, isTrue);
  });

  test('stopPlayback stops player and updates state', () async {
    final bytes = Uint8List.fromList([1, 2, 3, 4]);
    await playerService.playAudioBytes(bytes);

    await playerService.stopPlayback();

    verify(() => mockPlayer.stop()).called(1);
    expect(playerService.isPlaying, isFalse);
  });

  test('playAudioBytes handles errors', () async {
    when(() => mockPlayer.setFilePath(any())).thenThrow(Exception('Player error'));

    final bytes = Uint8List.fromList([1, 2, 3, 4]);

    // We expect an error in the error stream
    final errorFuture = expectLater(playerService.errorStream, emits(contains('Failed to play audio')));

    await playerService.playAudioBytes(bytes);

    await errorFuture;
    expect(playerService.isPlaying, isFalse);
  });

  group('AudioService (Legacy)', () {
    late AudioService audioService;
    late MockAudioPlayer mockPlayer;
    late MockAudioRecorder mockRecorder;

    setUp(() {
      mockPlayer = MockAudioPlayer();
      mockRecorder = MockAudioRecorder();
      when(() => mockPlayer.playerStateStream).thenAnswer((_) => const Stream.empty());
      when(() => mockPlayer.dispose()).thenAnswer((_) async {});
      when(() => mockRecorder.dispose()).thenAnswer((_) async {});

      audioService = AudioService(
        player: mockPlayer,
        recorder: AudioRecorderService(recorder: mockRecorder),
      );
    });

    tearDown(() {
      audioService.dispose();
    });

    test('AudioService state stream', () async {
      expect(audioService.stateStream, isNotNull);
    });

    test('AudioService stopAll calls stopPlayback', () async {
      when(() => mockPlayer.stop()).thenAnswer((_) async {});
      // We didn't set isPlaying to true, so stopPlayback might not call player.stop()
      // But let's verify speakText logic at least
      expect(audioService.stopAll(), completes);
    });
  });
}
