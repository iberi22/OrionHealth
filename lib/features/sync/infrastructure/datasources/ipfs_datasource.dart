import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class IpfsDatasource {
  final Dio _dio;
  final String _baseUrl;

  IpfsDatasource(this._dio)
      : _baseUrl = 'http://localhost:5001/api/v0';

  /// Adds data to IPFS and returns the CID.
  Future<String> add(Uint8List data) async {
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(data, filename: 'file'),
      });

      final response = await _dio.post(
        '$_baseUrl/add',
        data: formData,
      );

      if (response.statusCode == 200) {
        return response.data['Hash'] as String;
      } else {
        throw Exception('Failed to add data to IPFS: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('IPFS add failed: $e');
    }
  }

  /// Retrieves data from IPFS for a given CID.
  Future<Uint8List> get(String cid) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/cat',
        queryParameters: {'arg': cid},
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.statusCode == 200) {
        return Uint8List.fromList(response.data as List<int>);
      } else {
        throw Exception('Failed to get data from IPFS: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('IPFS get failed: $e');
    }
  }

  /// Pins a CID to the local IPFS node.
  Future<void> pin(String cid) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/pin/add',
        queryParameters: {'arg': cid},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to pin CID to IPFS: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('IPFS pin failed: $e');
    }
  }
}
