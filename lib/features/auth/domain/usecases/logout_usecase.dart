import 'package:injectable/injectable.dart';
import '../repositories/auth_repository.dart';
import '../../infrastructure/services/encryption_service.dart';

@injectable
class LogoutUseCase {
  final AuthRepository _repository;
  final EncryptionService _encryptionService;

  LogoutUseCase(this._repository, this._encryptionService);

  Future<void> call() async {
    _encryptionService.clearHealthKeyCache();
    await _repository.deleteSession();
  }
}
