import 'dart:convert';

/// ASR file metadata for a model asset.
class AsrFileMeta {
  final String url;
  final String md5;
  final int sizeBytes;

  const AsrFileMeta({required this.url, required this.md5, required this.sizeBytes});

  factory AsrFileMeta.fromJson(Map<String, dynamic> json) => AsrFileMeta(
        url: json['url'] as String,
        md5: json['md5'] as String,
        sizeBytes: (json['size_bytes'] as num).toInt(),
      );

  Map<String, dynamic> toJson() => {
        'url': url,
        'md5': md5,
        'size_bytes': sizeBytes,
      };
}

/// ASR model entry.
class AsrModelEntry {
  final String key;
  final String name;
  final String language;
  final String type; // e.g., 'sense_voice', 'whisper'
  final List<AsrFileMeta> files;

  const AsrModelEntry({
    required this.key,
    required this.name,
    required this.language,
    required this.type,
    required this.files,
  });

  factory AsrModelEntry.fromJson(Map<String, dynamic> json) => AsrModelEntry(
        key: json['key'] as String,
        name: json['name'] as String,
        language: json['language'] as String,
        type: json['type'] as String,
        files: (json['files'] as List<dynamic>)
            .map((e) => AsrFileMeta.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'key': key,
        'name': name,
        'language': language,
        'type': type,
        'files': files.map((e) => e.toJson()).toList(),
      };
}

/// Manifest for ASR models.
class AsrModelManifest {
  final List<AsrModelEntry> models;

  const AsrModelManifest({required this.models});

  factory AsrModelManifest.empty() => const AsrModelManifest(models: []);

  factory AsrModelManifest.fromJson(Map<String, dynamic> json) => AsrModelManifest(
        models: (json['models'] as List<dynamic>? ?? [])
            .map((e) => AsrModelEntry.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'models': models.map((e) => e.toJson()).toList(),
      };

  static AsrModelManifest parse(String jsonString) {
    return AsrModelManifest.fromJson(json.decode(jsonString) as Map<String, dynamic>);
  }

  String stringify() => json.encode(toJson());
}
