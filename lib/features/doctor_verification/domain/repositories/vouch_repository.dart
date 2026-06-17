import '../entities/vouch.dart';

abstract class VouchRepository {
  Future<List<Vouch>> getByDoctor(String doctorId);
  Future<void> addVouch(Vouch vouch);
  Future<bool> verifyVouchChain(String doctorId, {int depth = 3});
}
