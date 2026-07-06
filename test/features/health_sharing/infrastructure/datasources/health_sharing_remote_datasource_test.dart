import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orionhealth_health/features/health_sharing/infrastructure/datasources/health_sharing_remote_datasource.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late HealthSharingRemoteDataSource datasource;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    datasource = HealthSharingRemoteDataSource(mockDio);
  });

  group('HealthSharingRemoteDataSource', () {
    const baseUrl = 'https://api.orionhealth.ai/sharing/send';
    const payload = 'test_payload';

    test('sendPackageViaNfc returns true on success', () async {
      when(() => mockDio.post(baseUrl, data: any(named: 'data')))
          .thenAnswer((_) async => Response(
                statusCode: 200,
                requestOptions: RequestOptions(path: baseUrl),
              ));

      final result = await datasource.sendPackageViaNfc(payload);
      expect(result, isTrue);
      verify(() => mockDio.post(baseUrl, data: {'method': 'nfc', 'payload': payload})).called(1);
    });

    test('sendPackageViaBle returns false on error', () async {
      when(() => mockDio.post(baseUrl, data: any(named: 'data')))
          .thenThrow(DioException(requestOptions: RequestOptions(path: baseUrl)));

      final result = await datasource.sendPackageViaBle(payload);
      expect(result, isFalse);
    });

    test('sendPackageViaWifi returns false on non-200 status', () async {
      when(() => mockDio.post(baseUrl, data: any(named: 'data')))
          .thenAnswer((_) async => Response(
                statusCode: 500,
                requestOptions: RequestOptions(path: baseUrl),
              ));

      final result = await datasource.sendPackageViaWifi(payload);
      expect(result, isFalse);
    });
  });
}
