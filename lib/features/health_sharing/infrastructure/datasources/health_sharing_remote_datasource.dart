import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class HealthSharingRemoteDataSource {
  final Dio _dio;
  static const String _baseUrl = 'https://api.orionhealth.ai/sharing';

  HealthSharingRemoteDataSource(this._dio);

  Future<bool> sendPackageViaNfc(String payload) async {
    // In a real implementation, this might notify a relay or log the transfer
    return _sendPayload('nfc', payload);
  }

  Future<bool> sendPackageViaBle(String payload) async {
    return _sendPayload('ble', payload);
  }

  Future<bool> sendPackageViaWifi(String payload) async {
    return _sendPayload('wifi', payload);
  }

  Future<bool> _sendPayload(String method, String payload) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/send',
        data: {'method': method, 'payload': payload},
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
