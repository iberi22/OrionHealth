import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import '../../domain/entities/second_opinion.dart';
import '../../domain/repositories/second_opinion_repository.dart';

@LazySingleton(as: SecondOpinionRepository)
class IsarSecondOpinionRepository implements SecondOpinionRepository {
  final Isar isar;

  IsarSecondOpinionRepository(this.isar);

  @override
  Future<void> saveRequest(SecondOpinionRequest request) async {
    await isar.writeTxn(() async {
      await isar.secondOpinionRequests.put(request);
    });
  }

  @override
  Future<void> saveResponse(SecondOpinionResponse response) async {
    await isar.writeTxn(() async {
      await isar.secondOpinionResponses.put(response);
    });
  }

  @override
  Future<SecondOpinionRequest?> getRequest(String id) async {
    return isar.secondOpinionRequests.filter().idEqualTo(id).findFirst();
  }

  @override
  Future<List<SecondOpinionResponse>> getResponsesForRequest(String requestId) async {
    return isar.secondOpinionResponses.filter().requestIdEqualTo(requestId).findAll();
  }

  @override
  Future<List<SecondOpinionRequest>> getRequestsForPatient(String patientId) async {
    return isar.secondOpinionRequests.filter().patientIdEqualTo(patientId).findAll();
  }
}
