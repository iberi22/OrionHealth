import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import '../../domain/entities/vouch.dart';
import '../../domain/repositories/vouch_repository.dart';

@LazySingleton(as: VouchRepository)
class IsarVouchRepository implements VouchRepository {
  final Isar isar;

  IsarVouchRepository(this.isar);

  @override
  Future<List<Vouch>> getByDoctor(String doctorId) async {
    return isar.vouchs.filter().targetDoctorEqualTo(doctorId).findAll();
  }

  @override
  Future<void> addVouch(Vouch vouch) async {
    await isar.writeTxn(() async {
      await isar.vouchs.put(vouch);
    });
  }

  @override
  Future<bool> verifyVouchChain(String doctorId, {int depth = 3}) async {
    if (depth <= 0) return false;

    final vouches = await getByDoctor(doctorId);
    if (vouches.isEmpty) return false;

    // A simple chain verification: if any of the doctors who vouched for this doctor
    // is themselves vouched for (up to depth), we consider the chain verified.
    // In a real scenario, we might check for a root of trust.
    for (final vouch in vouches) {
      // Check if the voucher is verified (simplified)
      // This is a placeholder for more complex logic
      if (depth > 1) {
        final parentVerified = await verifyVouchChain(vouch.vouchedBy, depth: depth - 1);
        if (parentVerified) return true;
      } else {
        // At the end of depth, if we found vouches, we consider it a win for this simplified logic
        return true;
      }
    }

    return false;
  }
}
