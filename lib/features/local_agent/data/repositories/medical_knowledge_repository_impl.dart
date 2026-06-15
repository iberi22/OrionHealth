import '../../domain/entities/medical_code.dart';
import '../../domain/repositories/medical_knowledge_repository.dart';

class MedicalKnowledgeRepositoryImpl implements MedicalKnowledgeRepository {
  @override
  bool get isInitialized => false;
  @override
  Future<void> initialize({bool force = false}) async {}
  @override
  Future<MedicalCode?> searchByCode(String code) async => null;
  @override
  Future<MedicalCode?> searchByCodeInStandard(String code, String standard) async => null;
  @override
  Future<List<MedicalCode>> searchByTerm(String searchTerm) async => [];
  @override
  Future<List<MedicalCode>> searchByTermInStandard(String searchTerm, String standard) async => [];
  @override
  Future<List<MedicalCode>> searchByCategory(String category) async => [];
  @override
  Future<List<MedicalCode>> getAllCodes({String? standard}) async => [];
  @override
  Map<String, dynamic> getStats() => {'total': 0, 'initialized': false};
  @override
  Future<List<Map<String, dynamic>>> checkInteractions(List<String> drugCodes) async => [];
  @override
  List<Map<String, dynamic>> getSymptomMappings() => [];
}
