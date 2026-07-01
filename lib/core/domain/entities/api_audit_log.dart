import 'package:isar/isar.dart';

part 'api_audit_log.g.dart';

@collection
class ApiAuditLog {
  Id id = Isar.autoIncrement;

  final DateTime timestamp;

  final String apiName;

  final int originalPromptLength;

  final int scrubbedPromptLength;

  final bool piiFound;

  ApiAuditLog({
    required this.timestamp,
    required this.apiName,
    required this.originalPromptLength,
    required this.scrubbedPromptLength,
    required this.piiFound,
  });

  factory ApiAuditLog.fromJson(Map<String, dynamic> json) {
    return ApiAuditLog(
      timestamp: DateTime.parse(json['timestamp'] as String),
      apiName: json['apiName'] as String,
      originalPromptLength: json['originalPromptLength'] as int,
      scrubbedPromptLength: json['scrubbedPromptLength'] as int,
      piiFound: json['piiFound'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'apiName': apiName,
      'originalPromptLength': originalPromptLength,
      'scrubbedPromptLength': scrubbedPromptLength,
      'piiFound': piiFound,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApiAuditLog &&
          runtimeType == other.runtimeType &&
          timestamp == other.timestamp &&
          apiName == other.apiName &&
          originalPromptLength == other.originalPromptLength &&
          scrubbedPromptLength == other.scrubbedPromptLength &&
          piiFound == other.piiFound;

  @override
  int get hashCode =>
      timestamp.hashCode ^
      apiName.hashCode ^
      originalPromptLength.hashCode ^
      scrubbedPromptLength.hashCode ^
      piiFound.hashCode;
}
