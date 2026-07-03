import 'package:injectable/injectable.dart';
import '../entities/about_info.dart';
import '../repositories/i_about_repository.dart';

@injectable
class GetAppInfo {
  final IAboutRepository _repository;

  GetAppInfo(this._repository);

  Future<AboutInfo> execute() {
    return _repository.getAboutInfo();
  }
}
