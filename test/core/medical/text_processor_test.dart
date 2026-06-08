import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/core/medical/text_processor.dart';

void main() {
  group('TextProcessor', () {
    late TextProcessor defaultProcessor;

    setUp(() {
      defaultProcessor = TextProcessor();
    });

    group('cleanText', () {
      test('should normalize whitespace by default', () {
        const input = '  Patient has   high  blood pressure.  ';
        expect(defaultProcessor.cleanText(input), 'Patient has high blood pressure.');
      });

      test('should protect medical abbreviations from punctuation removal', () {
        final processor = TextProcessor(removePunctuation: true);
        const input = 'Patient is in the ICU, suffering from COPD.';
        // Punctuation removed, but abbreviations preserved
        final result = processor.cleanText(input);
        expect(result, contains('ICU'));
        expect(result, contains('COPD'));
      });

      test('should lowercase text when requested', () {
        final processor = TextProcessor(lowercase: true);
        const input = 'ADHD and HIV';
        expect(processor.cleanText(input), 'adhd and hiv');
      });

      test('should remove numbers but preserve medical measurements', () {
        final processor = TextProcessor(removeNumbers: true);
        const input = 'Patient age 45, BP 120/80, temp 98.6°F, took 2 pills.';
        final result = processor.cleanText(input);
        // "45" and "2" should be removed (replaced by space)
        // "120/80" and "98.6°F" should be preserved
        expect(result, contains('BP 120/80'));
        expect(result, contains('temp 98.6°F'));
        expect(result, isNot(contains('age 45')));
        expect(result, isNot(contains('took 2 pills')));
      });
    });

    group('segmentSentences', () {
      test('should split text into sentences', () {
        const input = 'Patient arrived at 10am. He was feeling dizzy! Is he stable?';
        final sentences = defaultProcessor.segmentSentences(input);
        expect(sentences, [
          'Patient arrived at 10am.',
          'He was feeling dizzy!',
          'Is he stable?'
        ]);
      });

      test('should protect medical abbreviations from causing splits', () {
        const input = 'The patient visited Dr. Smith. He took 50mg. of Aspirin.';
        final sentences = defaultProcessor.segmentSentences(input);
        expect(sentences, [
          'The patient visited Dr. Smith.',
          'He took 50mg. of Aspirin.'
        ]);
      });
    });

    group('extractDosages', () {
      test('should extract simple dosages', () {
        const input = 'Take 50mg of Aspirin and 10.5 ml of syrup twice a day.';
        final dosages = defaultProcessor.extractDosages(input);
        expect(dosages, containsAll(['50mg', '10.5 ml']));
      });

      test('should extract frequency dosages', () {
        const input = 'Apply 2 x / day.';
        final dosages = defaultProcessor.extractDosages(input);
        expect(dosages, contains('2 x / day'));
      });
    });

    group('extractVitalSigns', () {
      test('should extract various vital signs', () {
        const input = 'BP: 120/80, HR 72, temp 37.5°C, RR: 16, O2: 98%';
        final vitals = defaultProcessor.extractVitalSigns(input);
        expect(vitals, containsAll([
          'BP: 120/80',
          'HR 72',
          'temp 37.5°C',
          'RR: 16',
          'O2: 98%'
        ]));
      });
    });

    group('postprocessText', () {
      test('should capitalize first letter and trim', () {
        expect(TextProcessor.postprocessText('  low blood pressure'), 'Low blood pressure');
        expect(TextProcessor.postprocessText('already Capitalized'), 'Already Capitalized');
        expect(TextProcessor.postprocessText(''), '');
        expect(TextProcessor.postprocessText('   '), '');
      });
    });
  });
}
