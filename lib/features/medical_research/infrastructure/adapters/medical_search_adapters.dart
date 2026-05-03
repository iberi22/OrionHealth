import 'package:dio/dio.dart';
import '../../domain/models/research_result.dart';

abstract class MedicalSearchAdapter {
  Future<List<ResearchResult>> search(String query);
}

class PubMedAdapter implements MedicalSearchAdapter {
  final Dio _dio;
  static const String _baseUrl = 'https://eutils.ncbi.nlm.nih.gov/entrez/eutils';

  PubMedAdapter(this._dio);

  @override
  Future<List<ResearchResult>> search(String query) async {
    try {
      // 1. Search for IDs
      final searchResponse = await _dio.get('$_baseUrl/esearch.fcgi', queryParameters: {
        'db': 'pubmed',
        'term': query,
        'retmode': 'json',
        'retmax': 5,
      });

      final ids = List<String>.from(searchResponse.data['esearchresult']['idlist'] ?? []);
      if (ids.isEmpty) return [];

      // 2. Fetch details for IDs
      final fetchResponse = await _dio.get('$_baseUrl/esummary.fcgi', queryParameters: {
        'db': 'pubmed',
        'id': ids.join(','),
        'retmode': 'json',
      });

      final results = <ResearchResult>[];
      final summaries = fetchResponse.data['result'];

      for (final id in ids) {
        final summary = summaries[id];
        if (summary != null) {
          results.add(ResearchResult(
            title: summary['title'] ?? 'No Title',
            content: summary['source'] ?? '',
            source: 'PubMed',
            url: 'https://pubmed.ncbi.nlm.nih.gov/$id/',
            metadata: {
              'pubdate': summary['pubdate'],
              'authors': (summary['authors'] as List?)?.map((a) => a['name']).toList(),
            },
          ));
        }
      }
      return results;
    } catch (e) {
      return [];
    }
  }
}

class FdaAdapter implements MedicalSearchAdapter {
  final Dio _dio;
  static const String _baseUrl = 'https://api.fda.gov/drug/label.json';

  FdaAdapter(this._dio);

  @override
  Future<List<ResearchResult>> search(String query) async {
    try {
      final response = await _dio.get(_baseUrl, queryParameters: {
        'search': 'generic_name:"$query" OR brand_name:"$query"',
        'limit': 3,
      });

      final results = <ResearchResult>[];
      final data = response.data['results'] as List?;

      if (data != null) {
        for (final item in data) {
          results.add(ResearchResult(
            title: item['openfda']?['brand_name']?[0] ?? item['openfda']?['generic_name']?[0] ?? 'FDA Drug Info',
            content: item['indications_and_usage']?[0] ?? '',
            source: 'FDA (openFDA)',
            url: 'https://open.fda.gov/',
            metadata: {
              'manufacturer': item['openfda']?['manufacturer_name']?[0],
            },
          ));
        }
      }
      return results;
    } catch (e) {
      return [];
    }
  }
}

class WhoAdapter implements MedicalSearchAdapter {
  // ignore: unused_field
  final Dio _dio;
  WhoAdapter(this._dio);

  @override
  Future<List<ResearchResult>> search(String query) async {
    // WHO often doesn't have a public OData search API easily accessible for general content
    // For now, return empty or implement a placeholder search
    return [
      ResearchResult(
        title: 'WHO Information on $query',
        content: 'Searching WHO database for $query...',
        source: 'WHO',
        url: 'https://www.who.int/search?query=$query',
      )
    ];
  }
}
