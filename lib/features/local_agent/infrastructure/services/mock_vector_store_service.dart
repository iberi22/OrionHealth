import 'package:injectable/injectable.dart';
import '../../domain/services/vector_store_service.dart';

@LazySingleton(as: VectorStoreService)
class MockVectorStoreService implements VectorStoreService {
  final Map<String, String> _documents = {};

  @override
  Future<void> addDocument(String id, String content, Map<String, dynamic> metadata) async {
    _documents[id] = content;
    // In a real implementation, we would generate embeddings here.
  }

  @override
  Future<List<String>> search(String query, {int limit = 3}) async {
    // Mock search: just return documents that contain the query words
    // This is a naive keyword search for mocking purposes.
    final results = _documents.values
        .where((doc) => doc.toLowerCase().contains(query.toLowerCase()))
        .take(limit)
        .toList();

    if (results.isEmpty && _documents.isNotEmpty) {
       // Return random docs if no match, just to show something in UI
       return _documents.values.take(limit).toList();
    }

    return results;
  }
}
