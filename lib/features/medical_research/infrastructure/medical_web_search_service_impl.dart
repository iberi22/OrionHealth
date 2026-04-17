import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../domain/models/research_result.dart';
import '../domain/services/medical_web_search_service.dart';
import 'adapters/medical_search_adapters.dart';

@LazySingleton(as: MedicalWebSearchService)
class MedicalWebSearchServiceImpl implements MedicalWebSearchService {
  final Dio _dio;
  late final List<MedicalSearchAdapter> _adapters;

  MedicalWebSearchServiceImpl(this._dio) {
    _adapters = [
      PubMedAdapter(_dio),
      FdaAdapter(_dio),
      WhoAdapter(_dio),
    ];
  }

  @override
  Future<List<ResearchResult>> search(String query) async {
    final allResults = <ResearchResult>[];

    // Run all adapters in parallel
    final results = await Future.wait(_adapters.map((a) => a.search(query)));

    for (var adapterResults in results) {
      allResults.addAll(adapterResults);
    }

    // Sort by confidence or some criteria if available
    return allResults;
  }
}
