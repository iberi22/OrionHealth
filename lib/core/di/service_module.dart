import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import '../services/device_capability_service.dart';
import '../utils/health_helper.dart';
import '../utils/health_wrapper.dart';

@module
abstract class ServiceModule {
  @lazySingleton
  HealthWrapper get healthWrapper => HealthWrapper(HealthHelper.createClient());

  @preResolve
  @lazySingleton
  Future<FlutterSecureStorage> storage(
    DeviceCapabilityService capabilityService,
  ) async {
    return const FlutterSecureStorage(
      aOptions: AndroidOptions(),
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock_this_device,
      ),
    );
  }

  @lazySingleton
  FlutterAppAuth get appAuth => const FlutterAppAuth();

  @lazySingleton
  http.Client get httpClient => http.Client();
}
