import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/email-citas/domain/repositories/email_repository.dart';

class MockEmailRepository extends Mock implements EmailRepository {}

void main() {
  group('EmailRepository', () {
    late MockEmailRepository mockRepository;

    setUp(() {
      mockRepository = MockEmailRepository();
    });

    test('should connect to Gmail', () async {
      when(() => mockRepository.connectGmail()).thenAnswer((_) async => true);
      final result = await mockRepository.connectGmail();
      expect(result, isTrue);
      verify(() => mockRepository.connectGmail()).called(1);
    });

    test('should connect to Outlook', () async {
      when(() => mockRepository.connectOutlook()).thenAnswer((_) async => true);
      final result = await mockRepository.connectOutlook();
      expect(result, isTrue);
      verify(() => mockRepository.connectOutlook()).called(1);
    });

    test('should handle Gmail connection failure', () async {
      when(() => mockRepository.connectGmail()).thenAnswer((_) async => false);
      final result = await mockRepository.connectGmail();
      expect(result, isFalse);
    });

    test('should throw when connecting fails', () async {
      when(() => mockRepository.connectGmail()).thenThrow(Exception('Auth error'));
      expect(
        () => mockRepository.connectGmail(),
        throwsA(isA<Exception>()),
      );
    });
  });
}
