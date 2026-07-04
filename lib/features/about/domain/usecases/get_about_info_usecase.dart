import 'package:injectable/injectable.dart';
import '../entities/about_info.dart';
import '../repositories/i_about_repository.dart';

@injectable
class GetAboutInfoUseCase {
  final IAboutRepository repository;

  GetAboutInfoUseCase(this.repository);

  Future<AboutInfo> call() async {
    return repository.getAboutInfo();
  }
}
