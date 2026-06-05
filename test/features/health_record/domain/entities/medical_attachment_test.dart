import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/health_record/domain/entities/medical_attachment.dart';

void main() {
  group('MedicalAttachment', () {
    test('should create MedicalAttachment with provided values', () {
      final attachment = MedicalAttachment(
        localPath: '/path/to/file.pdf',
        mimeType: 'application/pdf',
        extractedText: 'Extracted text content',
      );

      expect(attachment.localPath, '/path/to/file.pdf');
      expect(attachment.mimeType, 'application/pdf');
      expect(attachment.extractedText, 'Extracted text content');
    });

    test('should allow null fields', () {
      final attachment = MedicalAttachment();

      expect(attachment.localPath, isNull);
      expect(attachment.mimeType, isNull);
      expect(attachment.extractedText, isNull);
    });

    test('should support value equality', () {
      final attachment1 = MedicalAttachment(
        localPath: 'path1',
        mimeType: 'type1',
        extractedText: 'text1',
      );
      final attachment2 = MedicalAttachment(
        localPath: 'path1',
        mimeType: 'type1',
        extractedText: 'text1',
      );
      final attachment3 = MedicalAttachment(
        localPath: 'path2',
        mimeType: 'type1',
        extractedText: 'text1',
      );

      expect(attachment1, equals(attachment2));
      expect(attachment1, isNot(equals(attachment3)));
      expect(attachment1.hashCode, equals(attachment2.hashCode));
    });

    test('should support serialization', () {
      final attachment = MedicalAttachment(
        localPath: '/path/to/file.pdf',
        mimeType: 'application/pdf',
        extractedText: 'Extracted text content',
      );

      final json = attachment.toJson();
      final fromJson = MedicalAttachment.fromJson(json);

      expect(fromJson, equals(attachment));
    });

    test('should handle validation', () {
      final validAttachment = MedicalAttachment(localPath: 'path.pdf');
      final invalidAttachment1 = MedicalAttachment(localPath: null);
      final invalidAttachment2 = MedicalAttachment(localPath: '');

      expect(validAttachment.isValid, isTrue);
      expect(invalidAttachment1.isValid, isFalse);
      expect(invalidAttachment2.isValid, isFalse);
    });

    test('should be type safe and handle boundary values', () {
      final attachment = MedicalAttachment(
        localPath: '',
        mimeType: '',
        extractedText: 'a' * 10000, // Large text
      );

      expect(attachment.localPath, '');
      expect(attachment.mimeType, '');
      expect(attachment.extractedText?.length, 10000);
    });
  });
}
