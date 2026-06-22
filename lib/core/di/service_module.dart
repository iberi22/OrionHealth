import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:http/http.dart' as http;
import 'package:device_calendar/device_calendar.dart';
import 'package:injectable/injectable.dart';

@module
abstract class ServiceModule {
  @lazySingleton
  FlutterSecureStorage get storage => const FlutterSecureStorage();

  @lazySingleton
  FlutterAppAuth get appAuth => const FlutterAppAuth();

  @lazySingleton
  http.Client get httpClient => http.Client();
}
