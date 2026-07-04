import 'package:injectable/injectable.dart';
import '../entities/auth_credentials.dart';
import '../repositories/auth_repository.dart';

@injectable
class SaveCredentialsUseCase {
  final AuthRepository repository;

  SaveCredentialsUseCase(this.repository);

  Future<void> call(AuthCredentials credentials) async {
    return repository.saveCredentials(credentials);
  }
}
