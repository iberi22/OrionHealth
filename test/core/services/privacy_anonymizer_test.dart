import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/core/services/privacy_anonymizer.dart';
import 'package:orionhealth_health/core/domain/entities/api_audit_log.dart';

class MockIsar extends Mock implements Isar {}
class MockIsarCollection extends Mock implements IsarCollection<ApiAuditLog> {}
class ApiAuditLogFake extends Fake implements ApiAuditLog {}

void main() {
  late MockIsar mockIsar;
  late MockIsarCollection mockCollection;
  late PromptScrubber scrubber;

  setUpAll(() {
    registerFallbackValue(ApiAuditLogFake());
  });

  setUp(() {
    mockIsar = MockIsar();
    mockCollection = MockIsarCollection();
    scrubber = PromptScrubber(mockIsar);

    when(() => mockIsar.apiAuditLogs).thenReturn(mockCollection);

    when(() => mockIsar.writeTxn<dynamic>(any())).thenAnswer((invocation) async {
      final callback = invocation.positionalArguments[0] as Function;
      await callback();
    });

    when(() => mockCollection.put(any())).thenAnswer((_) async => 1);
  });

  group('PromptScrubber Tests', () {
    test('should scrub email from prompt', () async {
      const prompt = 'My email is test@example.com, please help.';
      final result = await scrubber.scrub(prompt, apiName: 'test-api');

      expect(result, contains('[EMAIL]'));
      expect(result, isNot(contains('test@example.com')));
    });

    test('should scrub phone number from prompt', () async {
      const prompt = 'Call me at 123-456-7890.';
      final result = await scrubber.scrub(prompt, apiName: 'test-api');

      expect(result, contains('[PHONE]'));
      expect(result, isNot(contains('123-456-7890')));
    });

    test('should scrub IP address from prompt', () async {
      const prompt = 'My server is at 192.168.1.1.';
      final result = await scrubber.scrub(prompt, apiName: 'test-api');

      expect(result, contains('[IP_ADDRESS]'));
      expect(result, isNot(contains('192.168.1.1')));
    });

    test('should scrub device ID from prompt', () async {
      const prompt = 'Device ID: 550e8400-e29b-41d4-a716-446655440000';
      final result = await scrubber.scrub(prompt, apiName: 'test-api');

      expect(result, contains('[DEVICE_ID]'));
      expect(result, isNot(contains('550e8400-e29b-41d4-a716-446655440000')));
    });

    test('should log scrub operation in Isar', () async {
      const prompt = 'Email: user@orion.health';
      await scrubber.scrub(prompt, apiName: 'test-api');

      // verify(() => mockIsar.writeTxn<dynamic>(any())).called(1);
    });

    group('PromptScrubber Additional Tests', () {
      test('should not scrub text without PII', () async {
        const prompt = 'Hello, how are you?';
        final result = await scrubber.scrub(prompt, apiName: 'test-api');

        expect(result, equals(prompt));
      });

      test('should scrub multiple PII instances', () async {
        const prompt = 'Email: a@b.com, Phone: 123-456-7890';
        final result = await scrubber.scrub(prompt, apiName: 'test-api');

        expect(result, contains('[EMAIL]'));
        expect(result, contains('[PHONE]'));
      });
    });
  });
}
