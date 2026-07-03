import 'package:injectable/injectable.dart';
import '../repositories/i_about_repository.dart';

@injectable
class CheckUpdates {
  final IAboutRepository _repository;

  CheckUpdates(this._repository);

  Future<bool> execute() {
    return _repository.checkUpdates();
  }
}
