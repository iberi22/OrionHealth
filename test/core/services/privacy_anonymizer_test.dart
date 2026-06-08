import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/core/services/privacy_anonymizer.dart';
import 'package:orionhealth_health/core/domain/entities/api_audit_log.dart';
import 'package:orionhealth_health/core/medical/pii_detector.dart';

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
      return await callback();
    });

    when(() => mockCollection.put(any())).thenAnswer((_) async => 1);
  });

  group('PromptScrubber Tests', () {
    test('should scrub email from prompt', () async {
      const prompt = 'My email is test@example.com, please help.';
      final result = await scrubber.detectAndScrub(prompt, apiName: 'test-api');

      expect(result, contains('[EMAIL]'));
      expect(result, isNot(contains('test@example.com')));
    });

    test('should scrub phone number from prompt with context', () async {
      const prompt = 'My phone is (213) 456-7890.';
      final result = await scrubber.detectAndScrub(prompt, apiName: 'test-api');

      expect(result, contains('[PHONE]'));
      expect(result, isNot(contains('(213) 456-7890')));
    });

    test('should scrub IP address from prompt', () async {
      const prompt = 'My server is at 192.168.1.1.';
      final result = await scrubber.detectAndScrub(prompt, apiName: 'test-api');

      expect(result, contains('[IP_ADDRESS]'));
      expect(result, isNot(contains('192.168.1.1')));
    });

    test('should scrub UUID/device ID from prompt', () async {
      const uuid = '550e8400-e29b-41d4-a716-446655440000';
      final prompt = 'Device ID: $uuid';
      final result = await scrubber.detectAndScrub(prompt, apiName: 'test-api');

      expect(result, contains('[UUID]'));
      expect(result, isNot(contains(uuid)));
    });

    test('should scrub SSN with format preservation and context', () async {
      const prompt = 'ssn 213-45-6789.';
      final result = await scrubber.detectAndScrub(prompt, apiName: 'test-api');

      expect(result, contains('[XXX-XX-6789]'));
      expect(result, isNot(contains('213-45-6789')));
    });

    test('should scrub Credit Card with format preservation and context', () async {
      // 4111-1111-1111-1111 is a standard Luhn-valid Visa test number
      const validCC = '4111-1111-1111-1111';
      final result = await scrubber.detectAndScrub('Card payment: $validCC', apiName: 'test-api');

      expect(result, contains('[XXXX-XXXX-XXXX-1111]'));
      expect(result, isNot(contains(validCC)));
    });

    test('should maintain backward compatibility with scrub method', () async {
      const prompt = 'Email: test@example.com';
      final result = await scrubber.scrub(prompt, apiName: 'test-api');

      expect(result, contains('[EMAIL]'));
    });

    test('should log scrub operation in Isar', () async {
      const prompt = 'Email: user@orion.health';
      await scrubber.detectAndScrub(prompt, apiName: 'test-api');
    });

    test('PiiDetector standalone test', () {
      final detector = PiiDetector();
      final result = detector.detectPii('phone number: (213) 456-7890');
      expect(result.entities, isNotEmpty);
      expect(result.entities.first.label, equals('PHONE'));
    });

    test('PiiResult mask extension works', () {
      final detector = PiiDetector();
      final result = detector.detectPii('email: test@test.com');
      final masked = result.mask();
      expect(masked, contains('[EMAIL]'));
      expect(masked, isNot(contains('test@test.com')));
    });
  });
}
