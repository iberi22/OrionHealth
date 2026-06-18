import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/about/domain/entities/about_info.dart';
import 'package:orionhealth_health/features/about/domain/repositories/i_about_repository.dart';

class MockIAboutRepository extends Mock implements IAboutRepository {}

void main() {
  group('IAboutRepository', () {
    late MockIAboutRepository mockRepository;

    setUp(() {
      mockRepository = MockIAboutRepository();
    });

    test('should return about info', () async {
      final blogPost = BlogPost(
        title: 'Welcome',
        content: 'Welcome to OrionHealth',
        date: '2026-06-01',
        category: 'announcement',
      );
      final info = AboutInfo(
        blogPosts: [blogPost],
        missionStatement: 'Healthy lives',
        values: ['Integrity', 'Innovation'],
        activities: ['Research', 'Development'],
      );
      when(() => mockRepository.getAboutInfo()).thenAnswer((_) async => info);

      final result = await mockRepository.getAboutInfo();

      expect(result.missionStatement, 'Healthy lives');
      expect(result.values, ['Integrity', 'Innovation']);
      expect(result.blogPosts, [blogPost]);
      verify(() => mockRepository.getAboutInfo()).called(1);
    });

    test('should throw when repository fails', () async {
      when(() => mockRepository.getAboutInfo()).thenThrow(Exception('DB error'));
      expect(
        () => mockRepository.getAboutInfo(),
        throwsA(isA<Exception>()),
      );
    });
  });
}
