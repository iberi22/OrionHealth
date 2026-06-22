import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/core/services/asr/mock_asr_service.dart';
import 'package:orionhealth_health/core/services/asr/asr_types.dart';

void main() {
  late MockAsrService service;

  setUp(() {
    service = MockAsrService();
  });

  test('initialize sets state to ready', () async {
    await service.initialize();
    expect(service.state, AsrState.ready);
  });

  test('transcribe returns simulated text', () async {
    final result = await service.transcribe(Uint8List(0));
    expect(result, contains('transcripción simulada'));
    expect(service.state, AsrState.ready);
  });

  test('stop sets state to ready', () async {
    await service.stop();
    expect(service.state, AsrState.ready);
  });

  test('stateStream emits changes', () async {
    final states = <AsrState>[];
    service.stateStream.listen(states.add);

    final future = service.transcribe(Uint8List(0));
    // wait for state change to transcribing
    await Future.delayed(const Duration(milliseconds: 100));
    expect(states, contains(AsrState.transcribing));

    await future;
    // state might still be transcribing if microtask not run, but MockAsrService
    // updates state before completing future.
    // wait a bit for stream listener to be called
    await Future.delayed(Duration.zero);
    expect(states.last, AsrState.ready);
  });
}
