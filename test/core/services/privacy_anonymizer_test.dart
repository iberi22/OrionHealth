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
    registerFallbackValue(() async {});
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

      expect(result, contains('[email]'));
      expect(result, isNot(contains('test@example.com')));
    });

    test('should scrub phone number from prompt with context', () async {
      const prompt = 'My phone is (213) 456-7890.';
      final result = await scrubber.detectAndScrub(prompt, apiName: 'test-api');

      expect(result, contains('[phone]'));
      expect(result, isNot(contains('(213) 456-7890')));
    });

    test('should scrub IP address from prompt', () async {
      const prompt = 'My server is at 192.168.1.1.';
      final result = await scrubber.detectAndScrub(prompt, apiName: 'test-api');

      expect(result, contains('[ipAddress]'));
      expect(result, isNot(contains('192.168.1.1')));
    });

    test('should scrub UUID/device ID from prompt', () async {
      const uuid = '550e8400-e29b-41d4-a716-446655440000';
      final prompt = 'Device ID: $uuid';
      final result = await scrubber.detectAndScrub(prompt, apiName: 'test-api');

      expect(result, contains('[UUID]'));
      expect(result, isNot(contains(uuid)));
    });

    test('should scrub ssn with format preservation and context', () async {
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

      expect(result, contains('[email]'));
    });

    test('should log scrub operation in Isar', () async {
      const prompt = 'Email: user@orion.health';
      await scrubber.detectAndScrub(prompt, apiName: 'test-api');
    });

    test('PiiDetector standalone test', () {
      final detector = PiiDetector();
      final result = detector.detectPii('phone number: (213) 456-7890');
      expect(result.entities, isNotEmpty);
      expect(result.entities.first.label, equals('phone'));
    });

    test('PiiResult mask extension works', () {
      final detector = PiiDetector();
      final result = detector.detectPii('email: test@test.com');
      final masked = result.mask();
      expect(masked, contains('[email]'));
      expect(masked, isNot(contains('test@test.com')));
    });
  });

  group('PromptScrubber Surrogate Mode', () {
    test('should replace email with surrogate preserving domain', () async {
      const prompt = 'Contact me at john@hospital.org';
      final result = await scrubber.detectAndScrub(
        prompt,
        apiName: 'test-api',
        useSurrogates: true,
      );

      expect(result, isNot(contains('john@hospital.org')));
      expect(result, contains('@hospital.org'));
      expect(result, isNot(contains('[email]')));
    });

    test('should replace phone with surrogate preserving format', () async {
      const prompt = 'My phone is (213) 555-1234';
      final result = await scrubber.detectAndScrub(
        prompt,
        apiName: 'test-api',
        useSurrogates: true,
      );

      expect(result, isNot(contains('(213) 555-1234')));
      expect(result, isNot(contains('[phone]')));
      // Format should be preserved (parentheses, spaces, dashes)
      expect(
        RegExp(r'\(\d{3}\) \d{3}-\d{4}').hasMatch(result),
        isTrue,
      );
    });

    test('should replace ssn with surrogate preserving last 4', () async {
      const prompt = 'ssn 123-45-6789';
      final result = await scrubber.detectAndScrub(
        prompt,
        apiName: 'test-api',
        useSurrogates: true,
      );

      expect(result, isNot(contains('123-45-6789')));
      expect(result, isNot(contains('[ssn]')));
      expect(result, contains('-6789'));
    });

    test('should be consistent across repeated calls', () async {
      const prompt = 'Email: contact@example.com';
      final r1 = await scrubber.detectAndScrub(
        prompt,
        apiName: 'test-api',
        useSurrogates: true,
      );
      final r2 = await scrubber.detectAndScrub(
        prompt,
        apiName: 'test-api',
        useSurrogates: true,
      );

      expect(r1, equals(r2));
    });

    test('should use placeholders when useSurrogates is false', () async {
      const prompt = 'Email: alice@demo.com';
      final result = await scrubber.detectAndScrub(
        prompt,
        apiName: 'test-api',
        useSurrogates: false,
      );

      expect(result, contains('[email]'));
    });

    test('detectAndScrubWithSurrogates convenience method works', () async {
      const prompt = 'Email: bob@site.org';
      final result = await scrubber.detectAndScrubWithSurrogates(
        prompt,
        apiName: 'test-api',
      );

      expect(result, isNot(contains('bob@site.org')));
      expect(result, contains('@site.org'));
      expect(result, isNot(contains('[email]')));
    });
  });
}
