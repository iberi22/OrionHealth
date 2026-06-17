import '../entities/second_opinion.dart';

abstract class SecondOpinionRepository {
  Future<void> saveRequest(SecondOpinionRequest request);
  Future<void> saveResponse(SecondOpinionResponse response);
  Future<SecondOpinionRequest?> getRequest(String id);
  Future<List<SecondOpinionResponse>> getResponsesForRequest(String requestId);
  Future<List<SecondOpinionRequest>> getRequestsForPatient(String patientId);
}
