import 'package:injectable/injectable.dart';
import '../repositories/auth_repository.dart';

@injectable
class LogoutUseCase {
  final AuthRepository _repository;

  LogoutUseCase(this._repository);

  Future<void> call() async {
    await _repository.deleteSession();
  }
}
