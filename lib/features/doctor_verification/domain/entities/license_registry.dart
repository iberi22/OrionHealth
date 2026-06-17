import 'package:isar/isar.dart';

part 'license_registry.g.dart';

@collection
class LicenseRegistryLocal {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  final String countryCode;
  final List<String> hashes;

  LicenseRegistryLocal({
    required this.countryCode,
    required this.hashes,
  });
}
