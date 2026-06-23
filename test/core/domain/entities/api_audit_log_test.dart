import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/core/domain/entities/api_audit_log.dart';

void main() {
  group('ApiAuditLog', () {
    final timestamp = DateTime(2024, 1, 1, 12, 0, 0);

    test('should create ApiAuditLog instance with correct values', () {
      final log = ApiAuditLog(
        timestamp: timestamp,
        apiName: 'OpenAI',
        originalPromptLength: 100,
        scrubbedPromptLength: 80,
        piiFound: true,
      );

      expect(log.timestamp, timestamp);
      expect(log.apiName, 'OpenAI');
      expect(log.originalPromptLength, 100);
      expect(log.scrubbedPromptLength, 80);
      expect(log.piiFound, true);
    });

    test('should support equality', () {
      final log1 = ApiAuditLog(
        timestamp: timestamp,
        apiName: 'OpenAI',
        originalPromptLength: 100,
        scrubbedPromptLength: 80,
        piiFound: true,
      );
      final log2 = ApiAuditLog(
        timestamp: timestamp,
        apiName: 'OpenAI',
        originalPromptLength: 100,
        scrubbedPromptLength: 80,
        piiFound: true,
      );
      final log3 = ApiAuditLog(
        timestamp: timestamp.add(const Duration(seconds: 1)),
        apiName: 'OpenAI',
        originalPromptLength: 100,
        scrubbedPromptLength: 80,
        piiFound: true,
      );

      expect(log1, equals(log2));
      expect(log1, isNot(equals(log3)));
      expect(log1.hashCode, equals(log2.hashCode));
    });

    test('should serialize to JSON correctly', () {
      final log = ApiAuditLog(
        timestamp: timestamp,
        apiName: 'OpenAI',
        originalPromptLength: 100,
        scrubbedPromptLength: 80,
        piiFound: true,
      );

      final json = log.toJson();

      expect(json['timestamp'], timestamp.toIso8601String());
      expect(json['apiName'], 'OpenAI');
      expect(json['originalPromptLength'], 100);
      expect(json['scrubbedPromptLength'], 80);
      expect(json['piiFound'], true);
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'timestamp': timestamp.toIso8601String(),
        'apiName': 'OpenAI',
        'originalPromptLength': 100,
        'scrubbedPromptLength': 80,
        'piiFound': true,
      };

      final log = ApiAuditLog.fromJson(json);

      expect(log.timestamp, timestamp);
      expect(log.apiName, 'OpenAI');
      expect(log.originalPromptLength, 100);
      expect(log.scrubbedPromptLength, 80);
      expect(log.piiFound, true);
    });

    test('should round-trip JSON serialization', () {
      final originalLog = ApiAuditLog(
        timestamp: timestamp,
        apiName: 'Gemma',
        originalPromptLength: 50,
        scrubbedPromptLength: 50,
        piiFound: false,
      );

      final json = originalLog.toJson();
      final fromJson = ApiAuditLog.fromJson(json);

      expect(fromJson, equals(originalLog));
    });
  });
}
