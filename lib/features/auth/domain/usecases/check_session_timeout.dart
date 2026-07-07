import 'package:injectable/injectable.dart';
import '../repositories/auth_repository.dart';

@injectable
class CheckSessionTimeoutUseCase {
  final AuthRepository _repository;

  CheckSessionTimeoutUseCase(this._repository);

  Future<bool> call() async {
    final session = await _repository.getSession();
    if (session == null) return true;
    return session.isExpired;
  }
}
