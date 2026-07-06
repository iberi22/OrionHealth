import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/medication.dart';
import 'pharmacy_api_service.dart';

@LazySingleton(as: PharmacyApiService)
class RxNormApiService implements PharmacyApiService {
  final Dio _dio;
  static const String _baseUrl = 'https://rxnav.nlm.nih.gov/REST';

  RxNormApiService(this._dio);

  @override
  Future<List<Medication>> searchMedications(String query) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/drugs.json',
        queryParameters: {'name': query},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final drugGroup = data['drugGroup'];
        if (drugGroup != null && drugGroup['conceptGroup'] != null) {
          final List<Medication> results = [];
          for (var group in drugGroup['conceptGroup']) {
            if (group['conceptProperties'] != null) {
              for (var prop in group['conceptProperties']) {
                results.add(Medication(
                  name: prop['name'],
                  rxNormCode: prop['rxcui'],
                  genericName: prop['synonym'] ?? prop['name'],
                  startDate: DateTime.now(),
                ));
              }
            }
          }
          return results;
        }
      }
      return [];
    } catch (e) {
      // Log error or handle it
      return [];
    }
  }

  @override
  Future<Medication?> getMedicationDetails(String code) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/rxcui/$code/allProperties.json',
        queryParameters: {'propCategories': 'ATTRIBUTES'},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final propList = data['propConceptGroup']?['propConcept'];

        String? name;
        String? drugClass;
        String? genericName;

        if (propList != null) {
          for (var prop in propList) {
            final propName = prop['propName']?.toString().toUpperCase();
            final propValue = prop['propValue']?.toString();

            if (propName == 'RXNORM_NAME') name = propValue;
            if (propName == 'DRUG_CLASS') drugClass = propValue;
            if (propName == 'GENERIC_NAME') genericName = propValue;
          }
        }

        return Medication(
          name: name ?? 'Unknown Medication ($code)',
          rxNormCode: code,
          drugClass: drugClass,
          genericName: genericName,
          startDate: DateTime.now(),
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
