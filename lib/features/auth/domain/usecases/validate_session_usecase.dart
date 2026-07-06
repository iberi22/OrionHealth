import 'package:injectable/injectable.dart';
import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

@injectable
class ValidateSessionUseCase {
  final AuthRepository _repository;

  ValidateSessionUseCase(this._repository);

  Future<AuthSession?> call() async {
    final session = await _repository.getSession();
    if (session == null) return null;

    if (session.isExpired) {
      await _repository.deleteSession();
      return null;
    }

    return session;
  }
}
