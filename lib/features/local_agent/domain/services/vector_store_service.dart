abstract class VectorStoreService {
  Future<void> addDocument(String id, String content, Map<String, dynamic> metadata);
  Future<List<String>> search(String query, {int limit = 3});
}
