import '../entities/eps_provider.dart';
import '../entities/oauth_token.dart';

class OAuthLoginResult {
  final OAuthToken token;
  final String? patientId;

  OAuthLoginResult({required this.token, this.patientId});
}

class OAuthException implements Exception {
  final String message;
  final dynamic originalError;

  OAuthException(this.message, [this.originalError]);

  @override
  String toString() => 'OAuthException: $message${originalError != null ? ' ($originalError)' : ''}';
}

abstract class OAuthRepository {
  Future<OAuthLoginResult?> login(EPSProvider provider);
  Future<void> logout(String providerId);
  Future<OAuthToken?> getToken(String providerId);
  Future<String?> getPatientId(String providerId);
  Future<OAuthToken?> refreshToken(EPSProvider provider);
  Future<List<String>> getConnectedProviders();
  Future<EPSProvider?> getProviderDetails(String providerId);
}
