import '../entities/about_info.dart';

abstract class IAboutRepository {
  Future<AboutInfo> getAboutInfo();
}
