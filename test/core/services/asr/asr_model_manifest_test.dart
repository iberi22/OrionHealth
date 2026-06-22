import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/core/services/asr/asr_model_manifest.dart';

void main() {
  group('AsrModelManifest', () {
    const jsonStr = '''
    {
      "models": [
        {
          "key": "sense-voice-small",
          "name": "SenseVoice Small",
          "language": "es",
          "type": "sense_voice",
          "files": [
            {
              "url": "http://example.com/model.onnx",
              "md5": "1234567890abcdef1234567890abcdef",
              "size_bytes": 1000
            }
          ]
        }
      ]
    }
    ''';

    test('parse correctly decodes JSON', () {
      final manifest = AsrModelManifest.parse(jsonStr);
      expect(manifest.models, hasLength(1));
      expect(manifest.models[0].key, 'sense-voice-small');
      expect(manifest.models[0].files[0].url, 'http://example.com/model.onnx');
    });

    test('toJson and fromJson are symmetrical', () {
      final manifest = AsrModelManifest.parse(jsonStr);
      final json = manifest.toJson();
      final manifest2 = AsrModelManifest.fromJson(json);
      expect(manifest2.models[0].key, manifest.models[0].key);
      expect(manifest2.models[0].files[0].md5, manifest.models[0].files[0].md5);
    });

    test('empty manifest', () {
      final manifest = AsrModelManifest.empty();
      expect(manifest.models, isEmpty);
      expect(manifest.stringify(), '{"models":[]}');
    });
  });
}
