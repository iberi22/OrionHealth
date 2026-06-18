import 'package:equatable/equatable.dart';

class OAuthToken extends Equatable {
  final String accessToken;
  final String? idToken;
  final String? refreshToken;
  final DateTime? expiresAt;

  const OAuthToken({
    required this.accessToken,
    this.idToken,
    this.refreshToken,
    this.expiresAt,
  });

  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);

  @override
  List<Object?> get props => [accessToken, idToken, refreshToken, expiresAt];
}
