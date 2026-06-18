import 'package:flutter_test/flutter_test.dart';
import 'package:orionhealth_health/features/medical_research/domain/models/research_result.dart';

void main() {
  group('ResearchResult', () {
    const fullResult = ResearchResult(
      title: 'Diabetes Prevention Program',
      content: 'A comprehensive study on diabetes prevention...',
      source: 'PubMed Central',
      url: 'https://pmc.ncbi.nlm.nih.gov/articles/PMC1234567',
      confidence: 0.95,
      metadata: {
        'pubmed_id': '1234567',
        'publication_year': 2025,
        'study_type': 'RCT',
      },
    );

    const minimalResult = ResearchResult(
      title: 'Study Title',
      content: 'Content here',
      source: 'NIH',
      url: 'https://nih.gov/study',
    );

    group('constructor', () {
      test('assigns all fields correctly', () {
        expect(fullResult.title, 'Diabetes Prevention Program');
        expect(
          fullResult.content,
          'A comprehensive study on diabetes prevention...',
        );
        expect(fullResult.source, 'PubMed Central');
        expect(
          fullResult.url,
          'https://pmc.ncbi.nlm.nih.gov/articles/PMC1234567',
        );
        expect(fullResult.confidence, 0.95);
        expect(fullResult.metadata, {
          'pubmed_id': '1234567',
          'publication_year': 2025,
          'study_type': 'RCT',
        });
      });

      test('uses defaults for optional fields', () {
        expect(minimalResult.confidence, 0.0);
        expect(minimalResult.metadata, {});
      });
    });

    group('Equatable', () {
      test('equal results are equal', () {
        const a = ResearchResult(
          title: 'Test',
          content: 'Content',
          source: 'Source',
          url: 'https://test.com',
        );
        const b = ResearchResult(
          title: 'Test',
          content: 'Content',
          source: 'Source',
          url: 'https://test.com',
        );
        expect(a, equals(b));
      });

      test('different titles are not equal', () {
        const a = ResearchResult(
          title: 'A',
          content: 'Content',
          source: 'Source',
          url: 'https://test.com',
        );
        const b = ResearchResult(
          title: 'B',
          content: 'Content',
          source: 'Source',
          url: 'https://test.com',
        );
        expect(a, isNot(equals(b)));
      });

      test('different sources are not equal', () {
        const a = ResearchResult(
          title: 'Test',
          content: 'Content',
          source: 'PubMed',
          url: 'https://test.com',
        );
        const b = ResearchResult(
          title: 'Test',
          content: 'Content',
          source: 'FDA',
          url: 'https://test.com',
        );
        expect(a, isNot(equals(b)));
      });

      test('different urls are not equal', () {
        const a = ResearchResult(
          title: 'Test',
          content: 'Content',
          source: 'Source',
          url: 'https://a.com',
        );
        const b = ResearchResult(
          title: 'Test',
          content: 'Content',
          source: 'Source',
          url: 'https://b.com',
        );
        expect(a, isNot(equals(b)));
      });

      test(
        'different content alone does not affect equality (props = title, source, url)',
        () {
          const a = ResearchResult(
            title: 'Test',
            content: 'Content A',
            source: 'Source',
            url: 'https://test.com',
          );
          const b = ResearchResult(
            title: 'Test',
            content: 'Content B',
            source: 'Source',
            url: 'https://test.com',
          );
          // Only title, source, url are in props
          expect(a, equals(b));
        },
      );

      test('different confidence does not affect equality', () {
        const a = ResearchResult(
          title: 'Test',
          content: 'Content',
          source: 'Source',
          url: 'https://test.com',
          confidence: 0.5,
        );
        const b = ResearchResult(
          title: 'Test',
          content: 'Content',
          source: 'Source',
          url: 'https://test.com',
          confidence: 0.9,
        );
        expect(a, equals(b));
      });
    });
  });
}
