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

    group('getTermsAndConditions', () {
      test('returns terms when status code is 200 (String)', () async {
        const mockData = 'Terms and Conditions Content';
        when(() => mockDio.get(any())).thenAnswer(
          (_) async => Response(
            data: mockData,
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        final result = await datasource.getTermsAndConditions();

        expect(result, mockData);
        verify(() => mockDio.get(any(that: contains('/api/about/terms')))).called(1);
      });

      test('returns terms when status code is 200 (Map with content)', () async {
        final mockData = {'content': 'Terms from map'};
        when(() => mockDio.get(any())).thenAnswer(
          (_) async => Response(
            data: mockData,
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        final result = await datasource.getTermsAndConditions();

        expect(result, 'Terms from map');
      });

      test('returns null when status code is not 200', () async {
        when(() => mockDio.get(any())).thenAnswer(
          (_) async => Response(
            data: 'Not Found',
            statusCode: 404,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        final result = await datasource.getTermsAndConditions();

        expect(result, isNull);
      });

      test('returns null when an exception occurs', () async {
        when(() => mockDio.get(any())).thenThrow(DioException(requestOptions: RequestOptions(path: '')));

        final result = await datasource.getTermsAndConditions();

        expect(result, isNull);
      });
    });

    group('getPrivacyPolicy', () {
      test('returns privacy policy when status code is 200 (String)', () async {
        const mockData = 'Privacy Policy Content';
        when(() => mockDio.get(any())).thenAnswer(
          (_) async => Response(
            data: mockData,
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        final result = await datasource.getPrivacyPolicy();

        expect(result, mockData);
        verify(() => mockDio.get(any(that: contains('/api/about/privacy')))).called(1);
      });

      test('returns privacy policy when status code is 200 (Map with text)', () async {
        final mockData = {'text': 'Privacy from map'};
        when(() => mockDio.get(any())).thenAnswer(
          (_) async => Response(
            data: mockData,
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        final result = await datasource.getPrivacyPolicy();

        expect(result, 'Privacy from map');
      });

      test('returns null when status code is not 200', () async {
        when(() => mockDio.get(any())).thenAnswer(
          (_) async => Response(
            data: 'Error',
            statusCode: 500,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        final result = await datasource.getPrivacyPolicy();

        expect(result, isNull);
      });

      test('returns null when an exception occurs', () async {
        when(() => mockDio.get(any())).thenThrow(DioException(requestOptions: RequestOptions(path: '')));

        final result = await datasource.getPrivacyPolicy();

        expect(result, isNull);
      });
    });

    group('getAboutInfo', () {
      test('returns about info when status code is 200', () async {
        final mockData = {'mission': 'Our mission'};
        when(() => mockDio.get(any())).thenAnswer(
          (_) async => Response(
            data: mockData,
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        final result = await datasource.getAboutInfo();

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

        final result = await datasource.getAboutInfo();

        expect(result, isNull);
      });

      test('returns null when an exception occurs', () async {
        when(() => mockDio.get(any())).thenThrow(DioException(requestOptions: RequestOptions(path: '')));

        final result = await datasource.getAboutInfo();

        expect(result, isNull);
      });
    });

    group('fetchLatestBlogPosts', () {
      test('returns blog posts when status code is 200', () async {
        final mockData = [{'title': 'Post 1'}];
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

      test('returns null when an exception occurs', () async {
        when(() => mockDio.get(any())).thenThrow(DioException(requestOptions: RequestOptions(path: '')));
        final result = await datasource.fetchLatestBlogPosts();
        expect(result, isNull);
      });
    });

    group('fetchAppVersion', () {
      test('returns version when status code is 200 (Map)', () async {
        final mockData = {'version': '1.0.0'};
        when(() => mockDio.get(any())).thenAnswer(
          (_) async => Response(
            data: mockData,
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        final result = await datasource.fetchAppVersion();

        expect(result, '1.0.0');
        verify(() => mockDio.get(any(that: contains('/api/about/version')))).called(1);
      });

      test('returns version when status code is 200 (String)', () async {
        const mockData = '1.0.1';
        when(() => mockDio.get(any())).thenAnswer(
          (_) async => Response(
            data: mockData,
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ),
        );
        final result = await datasource.fetchAppVersion();
        expect(result, '1.0.1');
      });

      test('returns null when an exception occurs', () async {
        when(() => mockDio.get(any())).thenThrow(DioException(requestOptions: RequestOptions(path: '')));
        final result = await datasource.fetchAppVersion();
        expect(result, isNull);
      });
    });

    group('fetchAboutContent', () {
      test('calls getAboutInfo', () async {
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
      });
    });

    group('_extractText', () {
      test('handles Map with value key', () async {
        final mockData = {'value': 'value from map'};
        when(() => mockDio.get(any())).thenAnswer(
          (_) async => Response(
            data: mockData,
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ),
        );
        final result = await datasource.getTermsAndConditions();
        expect(result, 'value from map');
      });

      test('handles Map with unknown keys by using toString', () async {
        final mockData = {'unknown': 'some data'};
        when(() => mockDio.get(any())).thenAnswer(
          (_) async => Response(
            data: mockData,
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ),
        );
        final result = await datasource.getTermsAndConditions();
        expect(result, '{unknown: some data}');
      });
    });
  });
}
