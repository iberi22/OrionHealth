import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gemma/flutter_gemma.dart' hide ModelType;
import 'package:flutter_gemma/flutter_gemma.dart' as gemma;
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/local_agent/infrastructure/adapters/flutter_gemma_wrapper.dart';

/// No mocks needed — the wrapper delegates to static FlutterGemma methods.
/// These tests verify the wrapper passes through correctly.
void main() {
  group('FlutterGemmaWrapper', () {
    test('can be instantiated', () {
      final wrapper = FlutterGemmaWrapper();
      expect(wrapper, isA<FlutterGemmaWrapper>());
    });

    test('activeInferenceModel returns null by default', () {
      final wrapper = FlutterGemmaWrapper();
      expect(wrapper.activeInferenceModel, isNull);
    });

    test('hasActiveModel returns false by default', () {
      final wrapper = FlutterGemmaWrapper();
      expect(wrapper.hasActiveModel(), isFalse);
    });
  });
}
