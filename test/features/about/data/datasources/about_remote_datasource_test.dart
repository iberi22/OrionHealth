import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/about/data/datasources/about_remote_datasource.dart';

class MockDio extends Mock implements Dio {}

void main() {
  group('AboutRemoteDataSource', () {
    late AboutRemoteDataSource datasource;
    late MockDio mockDio;

    setUp(() {
      mockDio = MockDio();
      datasource = AboutRemoteDataSource(mockDio);
    });

    group('fetchLatestBlogPosts', () {
      test('returns blog posts when status code is 200', () async {
        final mockData = [
          {'title': 'Post 1', 'content': 'Content 1', 'date': '2024-01-01', 'category': 'Cat 1'}
        ];
        when(() => mockDio.get(any())).thenAnswer(
          (_) async => Response(
            data: mockData,
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        final result = await datasource.fetchLatestBlogPosts();

        expect(result, mockData);
        verify(() => mockDio.get(any(that: contains('/api/about/blog-posts')))).called(1);
      });

      test('returns null when status code is not 200', () async {
        when(() => mockDio.get(any())).thenAnswer(
          (_) async => Response(
            data: 'Not Found',
            statusCode: 404,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        final result = await datasource.fetchLatestBlogPosts();

        expect(result, isNull);
      });

      test('returns null when an exception occurs', () async {
        when(() => mockDio.get(any())).thenThrow(DioException(requestOptions: RequestOptions(path: '')));

        final result = await datasource.fetchLatestBlogPosts();

        expect(result, isNull);
      });
    });

    group('fetchAppVersion', () {
      test('returns version string when status code is 200', () async {
        final mockData = {'version': '1.2.3'};
        when(() => mockDio.get(any())).thenAnswer(
          (_) async => Response(
            data: mockData,
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        final result = await datasource.fetchAppVersion();

        expect(result, '1.2.3');
        verify(() => mockDio.get(any(that: contains('/api/about/version')))).called(1);
      });

      test('returns null when status code is not 200', () async {
        when(() => mockDio.get(any())).thenAnswer(
          (_) async => Response(
            data: 'Error',
            statusCode: 500,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        final result = await datasource.fetchAppVersion();

        expect(result, isNull);
      });
    });

    group('fetchAboutContent', () {
      test('returns about content when status code is 200', () async {
        final mockData = {'mission': 'Our mission'};
        when(() => mockDio.get(any())).thenAnswer(
          (_) async => Response(
            data: mockData,
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        final result = await datasource.fetchAboutContent();

        expect(result, mockData);
        verify(() => mockDio.get(any(that: contains('/api/about/content')))).called(1);
      });

      test('returns null when status code is not 200', () async {
        when(() => mockDio.get(any())).thenAnswer(
          (_) async => Response(
            data: 'Error',
            statusCode: 500,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        final result = await datasource.fetchAboutContent();

        expect(result, isNull);
      });
    });
  });
}
