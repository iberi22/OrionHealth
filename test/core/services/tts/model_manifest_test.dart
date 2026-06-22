import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/core/services/tts/model_manifest.dart';

void main() {
  group('TTSModelManifest', () {
    const jsonStr = '''
    {
      "voices": [
        {
          "key": "es-ES-standard",
          "language": "es-ES",
          "quality": "medium",
          "files": [
            {
              "url": "http://example.com/voice.onnx",
              "md5": "abcdefabcdefabcdefabcdefabcdefab",
              "size_bytes": 5000
            }
          ]
        }
      ]
    }
    ''';

    test('parse correctly decodes JSON', () {
      final manifest = TTSModelManifest.parse(jsonStr);
      expect(manifest.voices, hasLength(1));
      expect(manifest.voices[0].key, 'es-ES-standard');
      expect(manifest.voices[0].files[0].url, 'http://example.com/voice.onnx');
    });

    test('toJson and fromJson are symmetrical', () {
      final manifest = TTSModelManifest.parse(jsonStr);
      final json = manifest.toJson();
      final manifest2 = TTSModelManifest.fromJson(json);
      expect(manifest2.voices[0].key, manifest.voices[0].key);
    });

    test('empty manifest', () {
      final manifest = TTSModelManifest.empty();
      expect(manifest.voices, isEmpty);
    });
  });
}
