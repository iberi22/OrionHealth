import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:health/health.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import '../services/device_capability_service.dart';

@module
abstract class ServiceModule {
  @lazySingleton
  Health get health => Health();

  @preResolve
  @lazySingleton
  Future<FlutterSecureStorage> storage(DeviceCapabilityService capabilityService) async {
    final isEmulator = await capabilityService.isEmulator();
    return FlutterSecureStorage(
      aOptions: AndroidOptions(
        encryptedSharedPreferences: !isEmulator,
      ),
      iOptions: const IOSOptions(
        accessibility: KeychainAccessibility.first_unlock_this_device,
      ),
    );
  }

  @lazySingleton
  FlutterAppAuth get appAuth => const FlutterAppAuth();

  @lazySingleton
  http.Client get httpClient => http.Client();
}
