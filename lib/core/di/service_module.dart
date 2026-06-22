import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@module
abstract class ServiceModule {
  @preResolve
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();

  @lazySingleton
  FlutterSecureStorage get storage => const FlutterSecureStorage();

  @lazySingleton
  FlutterAppAuth get appAuth => const FlutterAppAuth();

  @lazySingleton
  http.Client get httpClient => http.Client();
}
