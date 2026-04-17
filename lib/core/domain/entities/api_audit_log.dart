import 'package:isar/isar.dart';

part 'api_audit_log.g.dart';

@collection
class ApiAuditLog {
  Id id = Isar.autoIncrement;

  DateTime timestamp;

  String apiName;

  int originalPromptLength;

  int scrubbedPromptLength;

  bool piiFound;

  ApiAuditLog({
    required this.timestamp,
    required this.apiName,
    required this.originalPromptLength,
    required this.scrubbedPromptLength,
    required this.piiFound,
  });
}
