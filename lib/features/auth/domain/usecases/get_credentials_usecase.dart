import 'package:injectable/injectable.dart';
import '../entities/auth_credentials.dart';
import '../repositories/auth_repository.dart';

@injectable
class GetCredentialsUseCase {
  final AuthRepository repository;

  GetCredentialsUseCase(this.repository);

  Future<AuthCredentials?> call() async {
    return repository.getCredentials();
  }
}
