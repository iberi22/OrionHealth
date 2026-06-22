import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:orionhealth_health/core/services/asr/asr_service.dart';
import 'package:orionhealth_health/core/services/asr/asr_types.dart';
import 'package:orionhealth_health/core/services/asr/asr_settings.dart';

void main() {
  group('AsrService', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({
        'asr_provider': 'mock'
      });
    });

    test('initialize loads mock adapter', () async {
      final service = AsrService();
      await service.initialize();
      expect(service.currentState, AsrState.ready);
      service.dispose();
    });

    test('transcribe uses adapter', () async {
      final service = AsrService();
      final text = await service.transcribe(Uint8List(0));
      expect(text, contains('simulada'));
      // service.dispose(); // Don't dispose if we have pending listeners from initialize
    });

    test('stateStream and errorStream are wired', () async {
      final service = AsrService();
      await service.initialize();

      final states = <AsrState>[];
      service.stateStream.listen(states.add);

      await service.transcribe(Uint8List(0));
      expect(states, contains(AsrState.transcribing));
    });
  });
}
